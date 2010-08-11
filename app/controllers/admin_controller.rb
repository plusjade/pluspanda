class AdminController < ApplicationController
  
  layout proc{ |c| c.request.xhr? ? false : "admin" }
  before_filter :require_user, :setup_user
  
  def index
  
  end
  
  def manage
  
  end
  
  def install  

  end
  
  def form
  
  end 
 
 
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
  
    
  private 
  
  def setup_user
    @user = current_user
  end
  
end
