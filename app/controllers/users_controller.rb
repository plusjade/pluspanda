class UsersController < ApplicationController
  layout "frontpage"
  before_filter :require_user, :except => [:new, :create, :reset_password]
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

  def reset_password
    render and return unless (params[:user] && params[:user][:email])

    if @user = User.find_by_email(params[:user][:email])
      @user.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +
      "Please check your email."
      redirect_to new_session_path
    else  
      flash[:notice] = "No user was found with that email address"  
    end
  end
end
