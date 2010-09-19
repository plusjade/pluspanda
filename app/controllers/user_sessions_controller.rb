class UserSessionsController < ApplicationController
  layout "frontpage"
  
  def new
    redirect_to admin_path if current_user
    @user_session = UserSession.new
  end
  
  def create
    redirect_to admin_path if current_user
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to admin_path
    else
      flash[:notice] = "Incorrect login information"
      render :action => :new
    end
  end
  
end
