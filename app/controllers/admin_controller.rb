class AdminController < ApplicationController

  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user

  def index
  end

  def install
  end

  def collect
  end

  def manage
  end

  def editor
  end

  def widget
    @theme = @user.standard_themes.get_staged
  end

  def thanks
  end

  def logout
    current_user_session.destroy
    redirect_to admin_frontpage
  end
end
