class ThemeController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user
  before_filter :ensure_attribute, :only => [:original, :staged, :update]

  # theme gallery?
  def index
    render :template => "theme/index", :layout => false
  end

  def new
    render :template => "theme/new", :layout => false
  end
  
  
  # install a new theme.
  def create
    name = params[:theme][:name]
    
    if @user.themes.count >= 5
      @message = "Your account only allows 5 themes."
    elsif @user.themes.find_by_name(name)
      @message = "This theme is already installed."
    else
      if @user.themes.create(params[:theme])
        @status = "good"
        @message = "Theme successfully installed."
      else
        @message = "There was a problem installing this theme."
      end
    end
      
    serve_json_response
  end


  # get original copy of staged attribute
  def original
      render :text => @attribute.original
  end


  # get staged copy of staged attribute
  def staged
    render :text => @attribute.staged    
  end


  # update staged copy of staged attribute.
  def update
    if @attribute.update_attributes(:staged => params['data'])
      @status  = "good"
      @message = "Theme data updated."
    else
      @message = "There was a problem saving the theme data."
    end
    
    serve_json_response
  end


  # parse staged attributes and generate file caches to serve in production.
  def publish
    @user.publish_theme
    @status = "good"
    @message = "Successfully published changes."

    serve_json_response
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
