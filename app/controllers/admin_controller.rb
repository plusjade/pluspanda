class AdminController < ApplicationController

  before_filter :require_user, :setup_user
  
  def index
  
  end
  
  def manage
  
  end
  
  def install  
  
  end
  
  def form
  
  end 
  
  private 
  
  def setup_user
    @user = current_user
  end
  
end
