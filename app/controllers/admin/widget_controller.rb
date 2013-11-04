class Admin::WidgetController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user
  before_filter {
    @theme = @user.standard_themes.get_staged
  }
  
  def index
    go
  end

  def css
    go
  end

  def testimonial
    go
  end
  def wrapper
    go
  end

  def settings
    go
  end

  def help
    go
  end

  def preview
    go
  end

  def staged
    theme = @user.standard_themes.get_staged
    @css = theme.get_attribute("style.css").staged
    @theme_config = theme.generate_theme_config(true)
    
    render :template => "admin/widget/staged", :layout => "staged"
  end

  def published
    render :template => "admin/widget/published", :layout => "published"
  end

  def go
    render({
      template: "#{ params["controller"] }/#{ params["action"] }",
      layout: !request.xhr? })
  end

end