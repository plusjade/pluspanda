class ThemeController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user
  before_filter :ensure_attribute, :except => [:publish]


  def original
      render :text => @attribute.original
  end

  def staged
    render :text => @attribute.staged    
  end

  # POST
  def update
    if @attribute.update_attributes(:staged => params['data'])
      @status  = "good"
      @message = "Theme data updated."
    else
      @message = "There was a problem saving the theme data."
    end
    
    serve_json_response
    return    
  end


  def publish
    @user.publish_theme
    render :text => "ok published"
  end  



  private
    
    def ensure_attribute
      a = params[:attribute] ? params[:attribute].gsub("-",".") : nil
      raise ActiveRecord::NotFound unless ThemeAttribute.names.include?(a)
      @attribute = @user.get_attribute(a)
      
    end
    

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
    
    
end
