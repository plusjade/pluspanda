class Api::WidgetController < ApplicationController

  before_filter {
    @user = User.find(params[:id])
    authorize! :edit, @user
  }

  def staged
    theme = @user.standard_themes.get_staged
    @css = theme.get_attribute("style.css").staged
    @theme_config = theme.generate_theme_config(true)

    render :template => "api/widget/staged", :layout => "staged"
  end

  def published
    render :template => "api/widget/published", :layout => "published"
  end

  def stock
    theme = ThemePackage.new(params[:theme_name])
    @css = theme.get_attribute("style.css")
    @theme_config = ThemeConfig.render({
      :theme_name   => theme.theme_name,
      :user         => @user,
      :stylesheet   => '',
      :wrapper      => theme.get_attribute("wrapper.html"),
      :testimonial  => theme.get_attribute("testimonial.html")
    })

    render template: "api/widget/staged", layout: "staged"
  end
end
