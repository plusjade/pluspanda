class Admin::PurchaseController < ApplicationController
  layout proc { |c| c.request.xhr? ? false : "admin"}
  
  before_filter :require_user, :setup_user

  def index
    go
  end
  
  def thanks
    go
  end
end