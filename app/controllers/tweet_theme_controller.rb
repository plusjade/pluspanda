class TweetThemeController < ThemeController
  
  before_filter :set_theme
  before_filter :ensure_attribute, :only => [:original, :staged, :update]
  
  def set_theme
    @theme = @user.tweet_themes.get_staged
  end
  
  
  def set_staged
    theme = @user.tweet_themes.find(params[:theme_id])
    
    @user.tweet_themes.update_all(:staged => false)
    theme.staged = true
    theme.save
    @status = "good"
    @message = "'#{TweetTheme.names[theme.name]}' theme is now staged."
    serve_json_response
  end
  
  # install and stage a new theme.
  def create
    params[:theme][:staged] = true
    
    if @user.tweet_themes.count >= 5
      @message = "Your account only allows 5 themes."
    elsif @user.tweet_themes.find_by_name(params[:theme][:name])
      @message = "This theme is already installed."
    else
      @user.tweet_themes.update_all(:staged => false)
      
      if @user.tweet_themes.create(params[:theme])
        @status = "good"
        @message = "Theme successfully installed."
      else
        @message = "There was a problem installing this theme."
      end
    end
      
    serve_json_response
  end
  
end