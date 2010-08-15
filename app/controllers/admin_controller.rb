class AdminController < ApplicationController
  
  layout proc{ |c| c.request.xhr? ? false : "admin" }
  before_filter :require_user, :setup_user
  
  def index
    @css_file = get_css_file
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
  
   
  # post to save tconfig settings
  def settings
    render :text => 'bad' and return unless request.put?
    
    if @user.tconfig.update_attributes(params[:tconfig])
      serve_json_response('good','Settings Updated')
    elsif !@user.tconfig.valid?
      serve_json_response('bad','Oops! Please make sure all fields are valid!')
    else
      serve_json_response
    end
    
    return
  end


  # post to save css file of current theme
  def save_css
    render :text => 'bad' and return unless request.post?

    path = File.join(@user.data_path, 'css', "#{@user.tconfig.theme}.css")
    f = File.new(path, "w+")
    f.write(params['css'])
    f.rewind

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
  
    
  private 
  
  def setup_user
    @user = current_user
  end

  
  def get_css_file
    path = File.join(@user.data_path, 'css', "#{@user.tconfig.theme}.css")
    f = File.open(path) 
    return f.read
  end  


end
