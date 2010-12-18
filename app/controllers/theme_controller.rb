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
    
    css = @user.get_staged_attribute("style.css")
    render :text => css.original
  end
    
  def css
    css = @user.get_staged_attribute("style.css")
    render :text => css.staged
  end
  
  # POST 
  def update_css
    css = @user.get_staged_attribute("style.css")
    
    if css.update_attributes(:staged => params['widget_css'])
      @status  = "good"
      @message = "CSS Updated."
    else
      @message = "There was a problem saving the css"
    end
    
    serve_json_response
    return
  end
    

  def publish
    
  end  


end
