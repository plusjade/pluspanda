class TweetThemeController < ThemeController
  
  before_filter :set_theme
  before_filter :ensure_attribute, :only => [:original, :staged, :update]
  
  def set_theme
    @theme = @user.tweet_themes.get_staged
  end
  
end