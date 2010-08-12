class AdminController < ApplicationController
  
  layout proc{ |c| c.request.xhr? ? false : "admin" }
  before_filter :require_user, :setup_user
  
  def index
    @css_file = get_css_file
  end
  
  def manage
  
  end
  
  def install  

  end
  
  def form
  
  end 
 
  # post to save tconfig settings
  def settings
    render :text => 'bad' and return unless request.put?
    
    if @user.tconfig.update_attributes(params[:tconfig])
      render :json => 
      {
        'status' => 'good',
        'msg'    => "Settings Updated!"
      }
    elsif !@user.tconfig.valid?
      render :json => 
      {
        'status' => 'bad',
        'msg'    => "Oops! Please make sure all fields are valid!"
      }
    else
      render :json => 
      {
        'status' => 'bad',
        'msg'    => "Oops! Please try again!"
      }
    end
  end

  # post to save css file of current theme
  def save_css
    render :text => 'bad' and return unless request.post?

    path = File.join(@user.data_path, 'css', "#{@user.tconfig.theme}.css")
    f = File.new(path, "w+")
    f.write(params['css'])
    f.rewind
        
    render :json => {
      'status' => 'good',
      'msg'    => "CSS Updated!"
    }

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
