class TestimonialsController < ApplicationController

  layout "testimonials"

  # TODO this is for testing only
  skip_before_filter :verify_authenticity_token

  def index
    @user = User.find_by_apikey!(params['apikey'])

    @active_tag   = (params['tag'].nil?)  ? 'all'    : params['tag']
    @active_sort  = (params['sort'].nil?) ? 'newest' : params['sort'].downcase
    @active_page  = (params['page'].nil? ) ? 1       : params['page'].to_i 
    @tags  = Tag.where({:user_id => @user.id })

    criteria = {
      user_id: @user.id,
      premium: @user.premium,
      limit: @user.tconfig.per_page,
      sort: @user.tconfig.sort,
      page: @active_page, 
      tag: @active_tag,
      created: @active_sort
    }

    @testimonials = Testimonial.from_user(criteria).map { |t| t.sanitize_for_api }
    update_data = Testimonial.update_data_payload(criteria.merge({
                    apikey: @user.apikey,
                    average: @user.testimonials.average(:rating).to_f
                  }))

    respond_to do |format|
      format.any(:html, :iframe) { render :text => 'a standalone version maybe?'}
      format.json do
        render json: {
          update_data: update_data,
          testimonials: @testimonials
        }
      end
      format.js do
        #@response.headers["Cache-Control"] = 'no-cache, must-revalidate'
        #@response.headers["Expires"] = 'Mon, 26 Jul 1997 05:00:00 GMT'
        render :js => "panda.display(#{@testimonials.to_json});panda.update(#{update_data.to_json});"
      end
    end
  end

  def new
    @user = User.find_by_apikey!(params['apikey'])
    @testimonial = Testimonial.new({
      :name  => params[:name],
      :email => params[:email],
      :meta  => params[:meta]
    })

    respond_to do |format|
      format.any(:html, :iframe) do
        render "editor", formats: [:html]
      end
    end
  end

  def create
    @user = User.find_by_apikey!(params['apikey'])

    params[:testimonial].delete('publish')
    params[:testimonial].delete('lock')

    unless can_publish_new
      @testimonial = Testimonial.new(testimonial_params)
      render "editor", formats: [:html]
      return
    end

    @testimonial = @user.testimonials.new(testimonial_params)

    if @testimonial.save
      UserMailer.new_testimonial(@user, @testimonial).deliver if @user[:is_via_api]
      @testimonial.freeze
      @status   = "good"
      @message  = "Testimonial created!"
      @resource = @testimonial

      if params["is_ajax"]
        serve_json_response
      else
        respond_to do |format|
          format.any(:html, :iframe) do
            flash[:success] = @message
            redirect_to "#{ edit_testimonial_path(@testimonial, apikey: @user.apikey) }"
          end
          format.json { serve_json_response }
        end
      end
    else
      if @testimonial.valid?
        @message = "Oops! An unknown error occured. Please try again." 
        respond_to do |format|
          format.any(:html, :iframe) { flash[:notice] = @message }
          format.json { serve_json_response }
        end
      else
        @message  = "Please make sure all fields are valid!"
        respond_to do |format|
          format.any(:html, :iframe) {
            flash[:notice] = @message
            @testimonial = Testimonial.new(testimonial_params)
            render "editor", formats: [:html]
          }
          format.json { serve_json_response }
        end
      end
    end
  end

  def edit
    @user = User.find_by_apikey!(params['apikey'])
    @testimonial = @user.testimonials.find(params[:id])

    respond_to do |format|
      format.any(:html, :iframe) do
        render "editor"
      end
    end
  end

  WritableAttributes = [
    :name,
    :location,
    :c_position,
    :position,
    :company,
    :rating,
    :url,
    :body,
    :publish,
    :lock,
    :email,
    :trash,
    :avatar
  ]

  def update
    @user = User.find_by_apikey!(params['apikey'])
    @testimonial = @user.testimonials.find(params[:id])

    params[:testimonial] ||= {}
    params[:testimonial].delete('publish')
    params[:testimonial].delete('lock')
    params.merge!(params[:testimonial])
    params.delete(:testimonial)

    if cannot?(:edit, @testimonial)
      # Throw exception
      @message = "This testimonial is locked!"

      respond_to do |format|
        format.any(:html, :iframe) do
          flash[:notice] = @message
          redirect_to "#{ edit_testimonial_path(@testimonial, apikey: @user.apikey) }"
        end
        format.json { render json: { message: @message }, status: 423 }
      end

      return
    end

    # temp hack to ensure core attributes are saved even if image fails
    if params && params[:avatar]
      core_attrs = params.dup
      core_attrs.delete(:avatar)
      attributes = WritableAttributes.dup - [:avatar]
      @testimonial.update_attributes(core_attrs.permit(*attributes))
    end

    if @testimonial.update_attributes(params.permit(*WritableAttributes))
      @status   = "good"
      @message  = "Testimonial Updated!"
      @resource = @testimonial

      if params["is_ajax"]
        serve_json_response
      else
        respond_to do |format|
          format.any(:html,:iframe) do 
            flash[:success] = @message
            redirect_to "#{ edit_testimonial_path(@testimonial, apikey: @user.apikey) }"
          end
          format.json { serve_json_response }
        end
      end
    else
      if @testimonial.valid?
        respond_to do |format|
          format.any(:html, :iframe) {
            flash[:notice] = @testimonial.errors.to_a.join(', ')
            redirect_to "#{ edit_testimonial_path(@testimonial, apikey: @user.apikey) }"
          }
          format.json { serve_json_response }
        end
      else
        @message = "Oops! Please make sure all fields are valid!"
        respond_to do |format|
          format.any(:html, :iframe) { flash[:notice] = @message }
          format.json { serve_json_response }
        end
      end
    end
  end

  private

  # verify this user can create a testimonial
  def can_publish_new
    access_key = @user.tconfig.form["require_key"]

    email = (testimonial_params[:email].nil?) ? '' : testimonial_params[:email].strip

    if access_key.present? && access_key != params[:access_key]
      flash[:notice] = "Invalid Access Key!"
    elsif testimonial_params[:name].nil? || testimonial_params[:name].strip.blank?
      flash[:notice] = "Please enter your full name."
    elsif @user.tconfig.form["email"] && (email.blank? || email.index('@') == nil)
      flash[:notice] = "Please enter a valid email address."
    else
      return true
    end

    false
  end

  def testimonial_params
    params.require(:testimonial).permit(*WritableAttributes)
  end
end
