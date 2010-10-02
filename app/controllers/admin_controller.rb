class AdminController < ApplicationController
  
  layout proc{ |c| c.request.xhr? ? false : "admin" }
  before_filter :require_user, :setup_user
  
  def index

  end
  
  def manage

  end
  
  
  def testimonials
    
    case params[:filter]
    when "published"
      order = (@user.tconfig.sort == 'position') ? "position ASC" : "created_at DESC"
      @testimonials = Testimonial.where({
        :user_id => current_user.id,
        :publish => true
      }).order(order)
    when "hidden"
      @testimonials = Testimonial.where({
        :user_id => current_user.id,
        :publish => false
      }).order("created_at DESC")
    else
      # default to new
      @testimonials = Testimonial.where({
        :user_id => current_user.id,
        :created_at => (Time.now - 2.day)..Time.now
      }).order("created_at DESC")      
    end
    
    render @testimonials
    return
     
  end
  
  def update
    puts params[:id]
    unless ['publish', 'hide', 'lock', 'unlock', 'delete'].include?(params[:do])
      @message = "Nothing Changed."
      serve_json_response
      return
    end 
    
    count = 0
    params[:id].each do |id|
      t = Testimonial.find_by_id(id.to_i, :conditions => { :user_id => @user.id } )
      next if t.nil?
      puts t.id
      case params[:do]
      when "publish"  
        t.publish = true
      when "hide"
        t.publish = false
      when "lock"
        t.lock = true
      when "unlock"
        t.lock = false
      when "tag"
        t.tag = params[:tag].to_i
      when "delete"
        # psuedo delete this
        # t.detete = true
      end
            
      (count = (count + 1)) if t.save
    end
    
    @status  = "good"
    @message = "#{count} Testimonials updated"
    serve_json_response
    return   
  end 
  
  
  def install  

  end
  
  
  def collect

  end 
 
  
  def staging
    render :template => "admin/staging", :layout => "staging"
  end
  
   
  # PUT to save tconfig settings
  def settings
    serve_json_response and return unless request.put?
    
    if @user.tconfig.update_attributes(params[:tconfig])
      @user.update_settings(self)
      @status  = "good"
      @message = "Settings updated"
    elsif !@user.tconfig.valid?
      @message = "Oops! Please make sure all fields are valid!"
    end

    serve_json_response
    return
  end

  def theme_css
    render :text => @user.theme_css
  end
  
  
  def theme_stock_css
    render :text => @user.theme_stock_css
  end


  # post to save css file of current theme
  def save_css
    server_json_response and return unless request.post?
    @user.update_css(params['widget_css'])
    @status  = "good"
    @message = "CSS Updated."
    serve_json_response
    return
  end
    
  
  def save_positions
    serve_json_response and return if params['tstml'].nil? or !params['tstml'].is_a?(Array) 
    
    params['tstml'].each_with_index do |id, position|
      testimonial = Testimonial.find(
        id, 
        :conditions => { :user_id => current_user.id }
      )
      testimonial.position = position
      testimonial.save
    end
    @status  = "good"
    @message = "Positions Saved!"
    serve_json_response
    return    
  end
  
  
  def logout
    current_user_session.destroy
    redirect_to admin_frontpage
  end  
  
    
  private 
  
  def setup_user
    @user = current_user
  end

end
