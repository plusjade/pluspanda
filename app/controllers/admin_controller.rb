class AdminController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user
  
  def index

  end

  # PUT 
  # Save tconfig settings #note rename to user.settings
  def settings
    if @user.tconfig.update_attributes(params[:tconfig])
      @status   = "good"
      @message  = "Settings updated"
      @resource = @user.tconfig
    elsif !@user.tconfig.valid?
      @message = "Oops! Please make sure all fields are valid!"
    end

    serve_json_response
    return
  end
  
    
#### testimonial stuff ####
  
  # GET    
  def testimonials
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

    render @user.testimonials.where(where).order(order)
    return
     
  end
  
  # GET
  # admin/testimonials/update
  def update
    unless ['publish', 'hide', 'lock', 'unlock', 'trash', 'untrash'].include?(params[:do])
      @message = "Invalid action."
      serve_json_response
      return
    end
     
    ids = params[:id].map! { |id| id.to_i }

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
    return   
  end 
    
  # GET
  # admin/testimonials/save_positions
  def save_positions
    if params['tstml'].nil? or !params['tstml'].is_a?(Array) 
      serve_json_response
      return
    end
    
    t_hash  = {}
    ids     = params['tstml'].map! { |id| id.to_i }
    @user.testimonials.find(ids).map { |t| t_hash[t.id.to_s] = t }
    ids.each_with_index do |id, position|
      t = t_hash[id.to_s]
      t.position = position
      t.save
    end
    
    @status  = "good"
    @message = "Positions Saved!"
    serve_json_response
    return    
  end
  
#### end testimonial stuff ####
         
  
  def logout
    current_user_session.destroy
    redirect_to admin_frontpage
  end  
  
end
