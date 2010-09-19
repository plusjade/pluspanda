class AdminController < ApplicationController
  
  layout proc{ |c| c.request.xhr? ? false : "admin" }
  before_filter :require_user, :setup_user
  
  def index

  end
  
  
  def manage
    @testimonials = Testimonial.where({ :user_id => current_user.id }).order("position ASC")
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
    render :text => 'bad' and return unless request.put?
    
    if @user.tconfig.update_attributes(params[:tconfig])
      @user.update_settings(self)
      serve_json_response('good','Settings Updated')
    elsif !@user.tconfig.valid?
      serve_json_response('bad','Oops! Please make sure all fields are valid!')
    else
      serve_json_response
    end
    
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
    render :text => 'bad' and return unless request.post?
    @user.update_css(params['widget_css'])
    serve_json_response('good','CSS Updated')
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
    serve_json_response('good', 'Positions Saved!')
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
