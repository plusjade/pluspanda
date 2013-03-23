class Admin::CollectController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user
  before_filter {
    @theme = @user.standard_themes.get_staged
  }
  
  def index
    go
  end

  def settings
    go
  end

  def help
    go
  end

end
