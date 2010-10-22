class PinkyController < ApplicationController

  before_filter :require_super_user
  
  def index
    @logs = WidgetLog.all
    @unique_users = WidgetLog.count("DISTINCT(user_id)")
    @unique_urls = WidgetLog.select("DISTINCT(url)") 
  end
  
  private
  
    def require_super_user
      pinky = YAML::load(File.open("#{::Rails.root.to_s}/config/pinky.yml"))
    
      unless params[:pk] == pinky["passkey"]
        render :text => "=("
      end
    
    end
end
