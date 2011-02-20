class PurchaseController < ApplicationController
  
  before_filter :require_user, :setup_user

  def index
    render :template => "purchase/index", :layout => false
  end
  
end