class Api::ThemeController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render(nothing: true, status: :unauthorized)
  end

  before_filter {
    @user = User.find(params[:id])
    authorize! :edit, @user
  }

  # parse staged attributes and generate file caches to serve in production.
  def publish
    @user.standard_themes.get_staged.publish
    @status = "good"
    @message = "Successfully published changes."

    serve_json_response
  end

  # install and stage a new theme.
  def create
    unless ThemePackage.themes.include?(params[:theme][:name])
      render(nothing: true, status: :not_found) and return
    end

    params[:theme][:theme_name] = params[:theme][:name]
    params[:theme][:staged] = true

    if @user.standard_themes.count >= 10
      @message = "Your account only allows 5 themes."
    elsif (theme = @user.standard_themes.find_by_theme_name(params[:theme][:name]))
      @user.standard_themes.update_all(:staged => false)
      theme.staged = true
      theme.save

      @status = "good"
      @message = "'#{theme.theme_name}' theme is now staged"
    else
      @user.standard_themes.update_all(:staged => false)

      if theme = @user.standard_themes.create(params[:theme])
        @status = "good"
        @message = "'#{theme.theme_name}' theme is now staged"
      else
        @message = theme.errors.to_a.join(' ')
      end
    end

    serve_json_response
  end
end
