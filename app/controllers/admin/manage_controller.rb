class Admin::ManageController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user

  def index
    @theme = @user.standard_themes.get_staged

    render({
      template: "#{ params["controller"] }/#{ params["action"] }",
      layout: !request.xhr?
    })
  end
  
  def help
    render({
      :template => "layouts/shared/main-content",
      :layout => !request.xhr? })
  end
end