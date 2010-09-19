class UserSessionsController < ApplicationController
  layout false
  before_filter :require_no_user
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to admin_path
    else
      render :action => :new
    end
  end
  
end
