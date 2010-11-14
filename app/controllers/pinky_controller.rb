class PinkyController < ApplicationController

  before_filter :require_super_user
  
  def index
    
    @logs = WidgetLog.order("id DESC").limit(50)
    @logs_count = WidgetLog.count
    @unique_users = WidgetLog.count("DISTINCT(user_id)")
    logs = WidgetLog.select("DISTINCT(url), user_id")
    
    @unique_urls = {}
    logs.map do |log| 
      if log.user_id && log.url && log.url =~ /https*:\/\/[^\/\?]+/i
        @unique_urls[log.user_id] = log.url.match(/https*:\/\/[^\/\?]+/i)[0]
      end 
    end
    #@unique_urls.uniq!
    
    
  end
  
  def users
    @users_count = User.count
    @users_newest = User.limit(50).order("id DESC")
    @users_active = User.limit(50).order("login_count DESC")
    
  end
  
  private
  
    def require_super_user
      pinky = YAML::load(File.open("#{::Rails.root.to_s}/config/pinky.yml"))
    
      unless params[:pk] == pinky["passkey"]
        render :text => "=("
      end
    
    end
end
