class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  helper_method :current_user_session, :current_user
    
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '1e2074d45c182ed5f3743d8d17ccd9c7'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  before_filter  :set_p3p

  def set_p3p
    response.headers["P3P"]='CP="CAO PSA OUR"'
  end  
  
  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end
    
    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to admin_frontpage
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to admin_frontpage
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.fullpath
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def serve_json_response
      rsp = {}
      @status  ||= 'bad'
      @message ||= 'Oops! Please try again!'
      
      # hack: newly created resources will be "frozen" as a way to identify them.
      if @resource
        name = @resource.class.to_s.downcase
        h = @resource.attributes
        h["type"]  = @resource.frozen? ? 'new' : 'existing'
        h["image"] = @resource.avatar.url(:sm) if @resource.respond_to?(:avatar) && @resource.avatar?
        h["path"]  = self.send(name + "_path", @resource) if self.respond_to?(name + "_path")
        
        rsp[name] = h
      end  
      
      rsp["status"] = @status
      rsp["msg"]    = @message
            
      # remember this param should be added with js.
      if params["is_ajax"]
        # respond to ajaxForm in hidden iframe (not xhr but still js)
        render :text => "<textarea>#{rsp.to_json}</textarea>"
      else
        render :json => rsp
      end
    end
    
    
    def current_theme_stock_css_path
      return Rails.root.join('app','views','testimonials','themes',@user.tconfig.theme, "#{@user.tconfig.theme}.css")
    end
    
    def admin_frontpage
      new_session_url
    end
    
    def root_url
      ::Rails.env == 'production' ? 'http://api.pluspanda.com' : 'http://localhost:3000'
    end
    
    def default_url_options(options = nil)
      options ||= {}
      options[:format] = :iframe if request.format == :iframe
      options
    end  
    
    def setup_user
      @user = current_user
    end  

    def go
      render({
        :template => "layouts/shared/main-content",
        :layout => !request.xhr? })
    end
end

