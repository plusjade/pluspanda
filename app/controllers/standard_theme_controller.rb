class StandardThemeController < ApplicationController

  layout proc { |c| c.request.xhr? ? false : "admin"}

  before_filter :ensure_attribute, :only => [:original, :staged, :update]
  before_filter :require_user, :setup_user
  before_filter {
    @theme = @user.standard_themes.get_staged
  }

  # theme gallery
  def index
    @themes  = Theme::Names

    render :template => "theme/index", :layout => false
  end

  # theme gallery theme
  def show
    raise ActiveRecord::NotFound unless Theme::Names.include?(params[:theme])

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
    path = File.join(Theme::Themes_path, Theme::Names[@theme.name], attribute)
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

  # install and stage a new theme.
  def create
    params[:theme][:name] = Theme::Names.index(params[:theme][:name])
    params[:theme][:staged] = true

    if @user.standard_themes.count >= 10
      @message = "Your account only allows 5 themes."
    elsif theme = @user.standard_themes.find_by_name(params[:theme][:name])
      puts "The first one"
      @user.standard_themes.update_all(:staged => false)
      theme.staged = true
      theme.save

      @status = "good"
      @message = "'#{theme.name_human}' theme is now staged"
    else
      puts "The seocond one"
      @user.standard_themes.update_all(:staged => false)

      if theme = @user.standard_themes.create(params[:theme])
        @status = "good"
        @message = "'#{theme.name_human}' theme is now staged"
      else
        @message = theme.errors.to_a.join(' ')
      end
    end

    serve_json_response
  end
end
