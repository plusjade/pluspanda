class PurchaseController < ApplicationController
  layout false
  
  before_filter :require_user, :setup_user

  def index

  end
  
  def thanks
    
  end
end