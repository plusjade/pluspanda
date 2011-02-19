class UsersController < ApplicationController
  layout "frontpage"
  before_filter :require_user, :except => [:new, :create]
  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  def new
    redirect_to admin_path if current_user
    @user = User.new
    @user_session = UserSession.new
  end
  
  
  def create
    create_as_api and return if params[:create_as_api]
    
    redirect_to admin_path if current_user
    @user = User.new(params[:user])
    if @user.save
      UserMailer.welcome(@user).deliver
      redirect_to("/admin")
    else
      flash[:warning] = "Make sure passwords match!"
      @user_session = UserSession.new
      render :action => :new
    end
  end
  
  def create_as_api
    @status = "bad"
    @token = nil
    from_pluspanda =  {
      :email => params[:email],
      :password => params[:password],
      :password_confirmation => params[:password_confirmation],
    }
    @user = User.new(from_pluspanda)
    if @user.save
      @status = "good"
      @token = @user.single_access_token
      UserMailer.welcome(@user).deliver
    else
      @message = @user.errors.to_a.join(", ")
    end
    
    render :json => {
      :status => @status,
      :message => @message,
      :single_access_token => @token
    }
    return true
  end
  
  def show
    @user = @current_user
    render :template => 
      'users/show',
      :layout => false if request.xhr?
  end


  def edit
    @user = @current_user
    render :template => 
      'users/edit',
      :layout => false if request.xhr?
  end
  
  
  def update
    if @current_user.update_attributes(params[:user])
      @status  = "good"
      @message = "Account Updated!"
    elsif !@user.valid?
      @message = 'Oops! Please make sure all fields are valid!'
    end
    
    serve_json_response
    return
  end
  
        
end
