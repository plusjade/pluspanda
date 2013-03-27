class TestimonialsController < ApplicationController
  
  layout proc{ |c| c.request.xhr? ? false : "testimonials" }
  before_filter :ensure_valid_user
  before_filter :ready_testimonial_filters_and_sorters, :only => [:index, :widget]

  def index
    @testimonials = @user.get_testimonials(
      :page     => @active_page, 
      :tag      => @active_tag,
      :created  => @active_sort
    )
    @testimonials.map! { |t| t.sanitize_for_api }
    
    total = @user.get_testimonials(:get_count => true)
    update_data = {
      "total"   => total,
      "average" => @user.testimonials.average(:rating).to_f,
    }

    offset = ( @active_page*@user.tconfig.per_page ) - @user.tconfig.per_page
    chunk = offset + @user.tconfig.per_page
    if (total > chunk) && ( @user.premium || (Testimonial::TrialLimit > chunk) )
      update_data["nextPageUrl"]  = root_url + testimonials_path + ".js?apikey=" + @user.apikey + '&tag=' + @active_tag + '&sort=' + @active_sort + '&page=' + (@active_page + 1).to_s
      update_data["nextPage"]     = @active_page + 1
      update_data["tag"]          = @active_tag
      update_data["sort"]         = @active_sort
    end
        
    respond_to do |format|
      format.any(:html, :iframe) { render :text => 'a standalone version maybe?'}
      format.json { 
        render :json => {
          :update_data  => update_data,
          :testimonials => @testimonials
        }
      }
      format.js  do
        #@response.headers["Cache-Control"] = 'no-cache, must-revalidate'
        #@response.headers["Expires"] = 'Mon, 26 Jul 1997 05:00:00 GMT'
        render :js => "panda.display(#{@testimonials.to_json});panda.update(#{update_data.to_json});"
      end
    end
    
  end

  # No longer using . See: routes.rb
  def widget 
    render :js => render_widget_js
  end
  
  # currently used to populate the rows in admin only.
  def show
    @testimonial = Testimonial.find_by_id(params[:id])
    @testimonial = (current_user) ? @testimonial : @testimonial.sanitize_for_api

    if @testimonial
      render @testimonial
    elsif @testimonial.nil?
      @message = "Invalid testimonial."
      respond_to do |format|
        format.any(:html, :iframe) { render :text => @message }
        format.json { render :json => serve_json_response }
        format.js   { render :js   => "alert('#{@message}');" }
      end 
    elsif params['apikey']
      respond_to do |format|
        format.any(:html, :iframe) { render :text => "todo: a public better singular html view..." }
        format.json { render :json => @testimonial }
        format.js   { render :js   => "pandaDisplayTstml(#{@testimonial.to_json});" }
      end
    end   

    return
  end


  # GET
  def new
    @testimonial = Testimonial.new({
      :name  => params[:name],
      :email => params[:email],
      :meta  => params[:meta]
    })

    # params[:apikey] prioritizes an apikey call over a logged in user
    # collector form iframe loads as public api so we want to emulate accurately.
    respond_to do |format|
      format.any(:html, :iframe) do
        if !params[:apikey] && current_user
          render 'editor.admin'
        else 
          render 'gatekeeper'
        end
      end
    end
  end


  #POST
  def create
    return unless is_able_to_publish

    @testimonial = @user.testimonials.new(params[:testimonial])
    
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
            flash[:notice] = @message
            redirect_to "#{edit_testimonial_path(@testimonial)}?apikey=#{@user.apikey}"
          end
          format.json { serve_json_response }
          format.js   { render :js   => "alert('#{@message}');" }
        end
      end
      return
    else  
      if !@testimonial.valid?
        @message  = "Please make sure all fields are valid!"
        respond_to do |format|
          format.any(:html, :iframe) { flash[:notice] = @message }
          format.json { serve_json_response and return }
          format.js   { render :js   => "alert('#{@message}');" and return}
        end
      else
        @message = "Oops! An unknown error occured. Please try again." 
        respond_to do |format|
          format.any(:html, :iframe) { flash[:notice] = @message }
          format.json { serve_json_response and return }
          format.js   { render :js   => "alert('#{@message}');" and return}
        end         
      end
      
      @testimonial = Testimonial.new(params[:testimonial])  
      render :action => "new"      
    end
  end


  def edit
    @testimonial = @user.testimonials.find_by_id(params[:id])
    if @testimonial
      respond_to do |format|
        format.any(:html, :iframe) do
          if @user[:is_via_api]
            render "editor.public"
          else
            render "editor.admin"
          end
        end
      end        
    else
      respond_to do |format|
        format.any(:html, :iframe) { render :text => "error! invalid testimonial" }
        format.json { render :json => {:status => "bad", :msg => "invalid testimonial"} }
        format.js   { render :js   => "alert('error! invalid testimonial');" }
      end
      return
    end
  end


  def update
    @testimonial = @user.testimonials.find_by_id(params[:id])
    render :text => "invalid testimonial" and return if @testimonial.nil?
    return unless is_able_to_publish
    
    if @testimonial.update_attributes(params[:testimonial])
      @status   = "good"
      @message  = "Testimonial Updated!"
      @resource = @testimonial

      if params["is_ajax"]
        serve_json_response
      else
        respond_to do |format|
          format.any(:html,:iframe) do 
            flash[:notice] = @message
            redirect_to "#{edit_testimonial_path(@testimonial)}?apikey=#{@user.apikey}"
          end
          format.json { json_response }
          format.js   { render :js   => "alert('something cool');" }
        end
      end
    else  
      if @testimonial.valid?
        @message = "Oops! Please make sure all fields are valid!"
        respond_to do |format|
          format.any(:html, :iframe) { flash[:notice] = @message }
          format.json { json_response }
          format.js   { render :js   => "alert('something cool');" }
        end
      else
        respond_to do |format|
          format.any(:html, :iframe) { 
            flash[:notice] = @testimonial.errors.to_a.join(', ')
            redirect_to "#{edit_testimonial_path(@testimonial)}?apikey=#{@user.apikey}"
          }
          format.json { json_response }
          format.js   { render :js   => "alert('something cool');" }
        end        
      end  
    end
  end


  private

    def ensure_valid_user
      # also ensure api calls are prioritized
      if current_user && params['apikey'].nil?
        @user = current_user
        return
      end 
    
      @user = User.find_by_apikey(params['apikey'])
      if @user.nil?
        @message = "error! invalid apikey"
        respond_to do |format|
          format.any(:html, :iframe) { render :text => @message }
          format.json { serve_json_response }
          format.js   { render :js   => "alert(#{@message});" }
        end
        return
      end

      @user[:is_via_api] = true
    end
  
    
    def ready_testimonial_filters_and_sorters
      @active_tag   = (params['tag'].nil?)  ? 'all'    : params['tag']
      @active_sort  = (params['sort'].nil?) ? 'newest' : params['sort'].downcase
      @active_page  = (params['page'].nil? ) ? 1       : params['page'].to_i 
    
      @tags  = Tag.where({:user_id => @user.id })
    end


    def is_able_to_publish
      return true if current_user && !@user[:is_via_api]
      params[:testimonial].delete('publish')
      params[:testimonial].delete('lock')
        
      return can_publish_existing if @testimonial
      return can_publish_new
    end
  
    # verify a testimonial is editable
    def can_publish_existing
      return true unless @testimonial.lock
    
      @message = "This testimonial is locked!"
      respond_to do |format|
        format.any(:html, :iframe) do
          flash[:notice] = "This testimonial is locked!"
          redirect_to "#{edit_testimonial_path(@testimonial)}?apikey=#{@user.apikey}"
        end
        format.json { serve_json_response }
        format.js   { render :js => "alert(#{@message});" }
      end    
      return false
    end 
  
    # verify this user can create a testimonial
    def can_publish_new
      access_key = @user.tconfig.form["require_key"]
    
      email = (params[:testimonial][:email].nil?) ? '' : params[:testimonial][:email].strip
    
      if !access_key.blank? && access_key != params[:access_key]
        flash[:notice] = "Invalid Access Key!"
      elsif params[:testimonial][:name].nil? || params[:testimonial][:name].strip.blank?
        flash[:notice] = "Please enter your full name."
      elsif @user.tconfig.form["email"] && (email.blank? || email.index('@') == nil)
        flash[:notice] = "Please enter a valid email address."
      else
        return true
      end

      redirect_to :back
      return false
    end
  

    def render_widget_js
      path = File.join('public','javascripts','widget',"widget.js")
      if File.exist?(path)
        File.open(path).read 
      else
        ";document.getElementById('plusPandaYes').innerHTML = 'pluspanda could not load widget.js';"
      end
    end
  
  
end
