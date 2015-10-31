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
    redirect_to admin_path if current_user
    @user = User.new(user_params)
    if @user.save
      UserMailer.welcome(@user).deliver
      redirect_to("/admin")
    else
      flash[:warning] = "Make sure passwords match!"
      @user_session = UserSession.new
      render :action => :new
    end
  end

  def reset_password
    render and return unless (params[:user] && params[:user][:email])

    if @user = User.find_by_email(user_params[:email])
      @user.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +
      "Please check your email."
      redirect_to new_session_path
    else
      flash[:notice] = "No user was found with that email address"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
