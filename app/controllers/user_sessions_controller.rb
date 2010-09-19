class UserSessionsController < ApplicationController
  layout "frontpage"
  before_filter :require_no_user
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to admin_path
    else
      flash[:notice] = "Incorrect login information"
      render :action => :new
    end
  end
  
end
