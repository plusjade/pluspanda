class AdminController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user
  
  # this should be the only interface to the admin.
  def index

  end

  def widget
    serve_json_response and return unless request.xhr?
    render :template => "admin/widget", :layout => false
  end
  
  def manage
    serve_json_response and return unless request.xhr?
    render :template => "admin/manage", :layout => false
  end
  
  def install  
    serve_json_response and return unless request.xhr?
    render :template => "admin/install", :layout => false
  end
  
  
  def collect
    serve_json_response and return unless request.xhr?
    render :template => "admin/collect", :layout => false
  end
  

  def staging
    render :template => "admin/staging", :layout => "staging"
  end
  
  # GET    
  def testimonials
    order = "created_at DESC"
    
    case params[:filter]
    when "published"
      where = {:publish => true}
      order = "position ASC" if @user.tconfig.sort == 'position'
    when "hidden"
      where = {:publish => false}
    else
      where = { :created_at => (Time.now - 2.day)..Time.now }
    end

    render @user.testimonials.where(where).order(order)
    return
     
  end
  
  # GET
  def update
    unless ['publish', 'hide', 'lock', 'unlock', 'delete'].include?(params[:do])
      @message = "Nothing Changed."
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
    when "delete"
      # psuedo delete this
      # t.detete = true
    end
    count = @user.testimonials.update_all(updates, :id => ids)

    @status  = "good"
    @message = "#{count} Testimonials updated"
    serve_json_response
    return   
  end 
    
   
  # PUT 
  # Save tconfig settings
  def settings
    serve_json_response and return unless request.put?
    
    if @user.tconfig.update_attributes(params[:tconfig])
      @user.update_settings
      @status   = "good"
      @message  = "Settings updated"
      @resource = @user.tconfig
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


  # POST 
  # Save current theme's css file
  def save_css
    @user.update_css(params['widget_css'])
    @status  = "good"
    @message = "CSS Updated."
    serve_json_response
    return
  end
    
    
  # GET
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
  
  
  def logout
    current_user_session.destroy
    redirect_to admin_frontpage
  end  
  
    
  private 
  
    def setup_user
      @user = current_user
    end
  
end
