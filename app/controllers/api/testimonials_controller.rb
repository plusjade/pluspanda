class Api::TestimonialsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render(nothing: true, status: :unauthorized)
  end

  before_filter {
    @user = User.find(params[:id])
    authorize! :edit, @user
  }

  def index
    order = "created_at DESC"

    case params[:filter]
    when "published"
      where = {:publish => true, :trash => false}
      order = "position ASC" if @user.tconfig.sort == 'position'
    when "hidden"
      where = {:publish => false, :trash => false}
    when "trash"
      where = {:trash => true}
    else
      where = { :created_at => (Time.now - 2.day)..Time.now, :trash => false }
    end

    limit = 30
    page = params[:page].to_i > 1 ? params[:page].to_i : 1
    offset = ( page*limit ) - limit

    query = @user.testimonials.where(where)
    total = query.count

    testimonials = query
      .order(order)
      .limit(limit)
      .offset(offset)
      .map do |t| 
        t.sanitize_for_api
          .merge(t.attributes)
          .merge({
            :share_url => "#{ view_context.root_url + view_context.edit_testimonial_path(t.id) }?apikey=#{ current_user.apikey }"
          })
    end

    render json: {
      testimonials: testimonials,
      total: total,
      next_page: (limit*page < total) ? page+1 : false 
    }
  end

  def update
    unless ['publish', 'hide', 'lock', 'unlock', 'trash', 'untrash'].include?(params[:do])
      @message = "Invalid action."
      serve_json_response
      return
    end

    ids = params[:ids].map! { |id| id.to_i }

    case params[:do]
    when "publish"
      updates = {:publish => true}
    when "hide"
      updates = {:publish => false}
    when "lock"
      updates = {:lock => true}
    when "unlock"
      updates = {:lock => false}
    when "tag"
      updates = {:tag => params[:tag].to_i}
    when "trash"
      updates = {:trash => true}
    when "untrash"
      updates = {:trash => false}  
    end
    count = @user.testimonials.update_all(updates, :id => ids)

    @status  = "good"
    @message = "#{count} Testimonials update with: #{params[:do]}"

    serve_json_response
  end 

  def save_positions
    if params['tstml'].nil? or !params['tstml'].is_a?(Array) 
      serve_json_response
      return
    end

    t_hash  = {}
    ids = params['tstml'].map! { |id| id.to_i }
    @user.testimonials.find(ids).map { |t| t_hash[t.id.to_s] = t }
    ids.each_with_index do |id, position|
      t = t_hash[id.to_s]
      t.position = position
      t.save
    end

    @status  = "good"
    @message = "Positions Saved!"

    serve_json_response
  end
end
