class Admin::ThemeController < ApplicationController

  layout false
  before_filter :require_user, :setup_user

  # parse staged attributes and generate file caches to serve in production.
  def publish
    @user.standard_themes.get_staged.publish
    @status = "good"
    @message = "Successfully published changes."

    serve_json_response
  end

  # install and stage a new theme.
  def create
    params[:theme][:name] = Theme::Names.index(params[:theme][:name])
    params[:theme][:staged] = true

    if @user.standard_themes.count >= 10
      @message = "Your account only allows 5 themes."
    elsif theme = @user.standard_themes.find_by_name(params[:theme][:name])
      @user.standard_themes.update_all(:staged => false)
      theme.staged = true
      theme.save

      @status = "good"
      @message = "'#{theme.name_human}' theme is now staged"
    else
      @user.standard_themes.update_all(:staged => false)

      if theme = @user.standard_themes.create(params[:theme])
        @status = "good"
        @message = "'#{theme.name_human}' theme is now staged"
      else
        @message = theme.errors.to_a.join(' ')
      end
    end

    serve_json_response
  end
end
