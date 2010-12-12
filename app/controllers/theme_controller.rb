class ThemeController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user
  

  def stock_css
    render :text => @user.theme_stock_css
  end
    
  def css
    render :text => @user.theme_css
  end
  
  # POST 
  # Save current theme's css file
  def update_css
    @user.update_css(params['widget_css'])
    @status  = "good"
    @message = "CSS Updated."
    serve_json_response
    return
  end
    
    
end
