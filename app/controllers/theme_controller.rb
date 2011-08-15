class ThemeController < ApplicationController
  
  layout proc { |c| c.request.xhr? ? false : "admin"}
  before_filter :require_user, :setup_user

  # theme gallery
  def index
    @themes  = @theme.class.names

    render :template => "theme/index", :layout => false
  end
  

  # theme gallery theme
  def show
    raise ActiveRecord::NotFound unless @theme.class.names.include?(params[:theme])

    @theme_config = @theme.class.render_theme_config(
      :user         => @user,
      :stylesheet   => "#{@theme.class::Themes_url}/#{params[:theme]}/style.css",
      :wrapper      => @theme.class.render_theme_attribute(params[:theme], "wrapper.html"),
      :testimonial  => @theme.class.render_theme_attribute(params[:theme], "testimonial.html")
    )   
    
    render :template => "theme/show", :layout => "staged"
  end
  
  
  # get original attributes from theme source.
  def original
    attribute = ThemeAttribute.names[@attribute.name]
    path = File.join(Theme::Themes_path, @theme.class.names[@theme.name], attribute)
    data = File.exist?(path) ? File.new(path).read : "/*No data*/"
    render :text => data
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
    @theme.publish
    @status = "good"
    @message = "Successfully published changes."

    serve_json_response
  end  

  def ensure_attribute
    a = nil
    if params[:attribute]
      a = params[:attribute].reverse
      a[a.index("-")] = "."
      a = a.reverse
    end
    
    raise ActiveRecord::NotFound unless ThemeAttribute.names.include?(a)
    @attribute = @theme.get_attribute(a)
  end
  
  
end
