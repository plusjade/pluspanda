class UsersController < ApplicationController
  layout "marketing"
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  
  def new
    @user = User.new
    @user_session = UserSession.new
  end
  
  
  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to("/admin")
    else
      @user_session = UserSession.new
      render :action => :new
    end
  end
  
  
  def show
    @user = @current_user
    render :template => 
      'users/show',
      :layout => false,
      :locals => {:user => @user} if request.xhr?
  end


  def edit
    @user = @current_user
    render :template => 
      'users/edit',
      :layout => false,
      :locals => {:user => @user} if request.xhr?
  end
  
  
  def update
    @user = @current_user
    if @user.update_attributes(params[:user])
      render :json => 
      {
        'status' => 'good',
        'msg'    => "Account Updated!"
      }
    elsif !@user.valid?
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
  
  
end
