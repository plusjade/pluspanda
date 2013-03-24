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
      @user_session.record.update_attributes(:last_login_at => Time.now)
      redirect_to admin_path
    else
      flash[:notice] = @user_session.errors.to_a.join(", ")
      render :action => :new
    end
  end
  
  def single_access
    @user = User.find_by_single_access_token(params[:single_access_token])
    
    if @user
      current_user_session.destroy if current_user_session
      UserSession.find.destroy if UserSession.find

      UserSession.create(@user)
      @user.single_access_token = SecureRandom.hex(10)
      @user.save
    end

    redirect_to admin_path
  end
  
end
