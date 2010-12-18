class ThemeController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user
  
=begin
  theme has 2 parts
  HTML template
    served via api
      /theme/
       returns { :wrapper => "", :testimonial => "" }
       should we serve a static representation?
  CSS
    served statically
      static url to a published.css
      updated as per the admin with appended timestamp querystring
=end


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
    

  def update_and_publish_css
    
  end  


end
