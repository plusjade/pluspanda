class StandardThemeController < ThemeController
  
  before_filter :set_theme
  before_filter :ensure_attribute, :only => [:original, :staged, :update]
  
  def set_theme
    @theme = @user.standard_themes.get_staged
  end


  def set_staged
    theme = @user.standard_themes.find(params[:theme_id])
    
    @user.standard_themes.update_all(:staged => false)
    theme.staged = true
    theme.save
    @status = "good"
    @message = "'#{StandardTheme.names[theme.name]}' theme is now staged."
    serve_json_response
  end
  
  
  # install and stage a new theme.
  def create
    params[:theme][:staged] = true
    
    if @user.standard_themes.count >= 5
      @message = "Your account only allows 5 themes."
    elsif @user.standard_themes.find_by_name(params[:theme][:name])
      @message = "This theme is already installed."
    else
      @user.standard_themes.update_all(:staged => false)
      
      if @user.standard_themes.create(params[:theme])
        @status = "good"
        @message = "Theme successfully installed."
      else
        @message = "There was a problem installing this theme."
      end
    end
      
    serve_json_response
  end
  
end