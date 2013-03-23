class Admin::InstallController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user

  def index
    @theme = @user.standard_themes.get_staged
    go
  end

end