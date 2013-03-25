class UserSessionsController < ApplicationController
  layout "frontpage"
  before_filter :require_no_user

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

  def perishable
    @user = User.find_using_perishable_token(params[:token])
    if @user && (session = UserSession.new(@user)) && session.save
      flash[:notice] = "Remember to reset your password!"
      redirect_to admin_account_path
    else
      flash[:notice] = "We could not locate your account. " +  
      "If you are having issues try copying and pasting the URL " +  
      "from your email into your browser or restarting the " +  
      "reset password process."  

      redirect_to new_session_path
    end
  end
end
