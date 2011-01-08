class PinkyController < ApplicationController

  before_filter :require_super_user
  
  def index
    
    @logs_top = WidgetLog.order("impressions DESC").limit(50)
    @logs_new = WidgetLog.order("id DESC").limit(50)
    @logs_count = WidgetLog.count  
  end
  
  def users
    @users_count = User.count
    @users_newest = User.limit(50).order("id DESC")
    @users_active = User.limit(50).order("login_count DESC")
    
  end
  
  def as_user
    user = User.find_by_email(params[:email])
    
    UserSession.create(user)
    
    redirect_to admin_path
  end
  
  private
    
    def require_super_user
      pinky = YAML::load(File.open("#{::Rails.root.to_s}/config/pinky.yml"))
    
      unless params[:pk] == pinky["passkey"]
        render :text => "=("
      end
    
    end
end
