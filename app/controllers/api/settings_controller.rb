class Api::SettingsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render(nothing: true, status: :unauthorized)
  end

  before_filter {
    @user = User.find(params[:id])
    authorize! :edit, @user
  }

  # Save tconfig settings #note rename to user.settings
  def update
    if @user.tconfig.update_attributes(settings_params)
      @status   = "good"
      @message  = "Settings updated"
      @resource = @user.tconfig
    elsif !@user.tconfig.valid?
      @message = "Oops! Please make sure all fields are valid!"
    end

    serve_json_response
  end

  private

  def settings_params
    params.require(:tconfig).permit(:per_page, :sort, :message, form: [:rating, :company, :location, :c_position, :website, :avatar, :require_key, :meta])
  end
end
