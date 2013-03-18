Pluspanda::Application.routes.draw do
  
  # legacy api
  resources :testimonials do
    get :widget, :on => :collection
  end
  
  # current api
  scope "v1" do
    resources :testimonials do
      # redirect the widget request amazon s3
      # s3 file is the user's themeConfig
      get :widget, :on => :collection, :to => proc {|env|
        apikey = env["QUERY_STRING"].split("=")[1]
        user = User.find_by_apikey(apikey)
        
        if Rails.env.development?
          # note in development we serve the staged attributes directly
          # even for "published" mode. so we always see staging in published.
          [200, {}, [user.standard_themes.get_staged.generate_theme_config]]
        else
          url    = user.standard_themes.get_staged.theme_config_url
          log    = Rails.root.join('log', 'widget.log')
          line   = "#{apikey}, #{env["HTTP_REFERER"]}, #{DateTime.now} \n"
          File.open(log, 'a') { |f| f.write(line) } if File.exist?(log)
          
          [307, {'Location' => url, 'Content-Type' => 'text/html'}, ["redirecting to: #{url}"]]
        end
      }
      get :widget, :on => :collection
    end
    
    resources :tweets do
      # redirect the widget request to the saved amazon s3 file.
      get :widget, :on => :collection, :to => proc {|env|
        apikey = env["QUERY_STRING"].split("=")[1]
        user = User.find_by_apikey(apikey)
                
        if Rails.env.development?
          [200, {}, [user.tweet_themes.get_staged.generate_tweet_bootstrap]]
        else
          url    = user.tweet_themes.get_staged.tweet_bootstrap_url
          log    = Rails.root.join('log', 'widget.log')
          line   = "#{apikey}, #{env["HTTP_REFERER"]}, #{DateTime.now} \n"
          File.open(log, 'a') { |f| f.write(line) } if File.exist?(log)
          
          [307, {'Location' => url, 'Content-Type' => 'text/html'}, ["redirecting to: #{url}"]]
        end
      }
      get :widget, :on => :collection
    end
    
  end

  # account management
  resource :account, :controller => "users", :only => [:new, :create]
  resource :session, :controller => "user_sessions" do
    get "single_access", :on => :member
  end

  namespace :admin do
    resource :account

    scope "/collect", :controller => :collect, :as => :collect do
      get "()", :action => :index
      get :help
      get :settings
    end
    
    scope "/purchase", :controller => :purchase, :as => :purchase do
      get "()", :action => :index
      get :thanks
    end

    scope "/install", :controller => :install, :as => :install do
      get "()", :action => :index
      get :help
    end

    scope "/manage", :controller => :manage, :as => :manage do
      get "()", :action => :index
      get :help
      get :settings
    end

    scope "/widget", :controller => :widget, :as => :widget do
      get "()", :action => :index
      get :preview
      get :settings
      get :css
      get :wrapper
      get :testimonial
      get :help

      get :staged
      get :published
    end
    
  end
  
  
  # admin
  scope "/admin", :controller => :admin, :as => :admin do
    get '/', :action => "index"

    scope "/testimonials", :as => :testimonials do
      get "()"                  ,:action => :testimonials
      get "/update"             ,:action => :update   
      get "/save_positions"     ,:action => :save_positions
    end

    scope "/theme", :controller => :standard_theme, :as => :theme do
      get "()"        ,:action => :index
      post "()"       ,:action => :create
      get "/publish"  ,:action => :publish
      get "/gallery/:theme"  ,:action => :show
      get "/:theme_id/stage"  ,:action => :set_staged
      
      scope "/:attribute" do
        get "()"          ,:action => :staged
        post "()"         ,:action => :update
        get "/original"   ,:action => :original
      end
    
    end

    put :settings
    get :logout
  end 
  
  
  # admin
  scope "/twitter", :controller => "twitter", :as => "twitter" do
    get '/', :action => "index"
    get :widget
    get :manage
    get :install
    get :collect
    get :staged
    get :published
    put :settings
    
    resources :tweets do
      get "trash", :on => :member
      get "save_positions", :on => :collection
    end

    scope "/theme", :controller => :tweet_theme, :as => :theme do
      get "()"        ,:action => :index
      post "()"       ,:action => :create
      get "/publish"  ,:action => :publish
      get "/gallery/:theme"  ,:action => :show
      get "/:theme_id/stage"  ,:action => :set_staged
      
      scope "/:attribute" do
        get "()"          ,:action => :staged
        post "()"         ,:action => :update
        get "/original"   ,:action => :original
      end
    
    end
  end

  # dashboard
  scope "/pinky", :controller => "pinky", :as => "pinky" do
    get "()" ,:action => "index"
    get "users"
    post "as_user"
  end
  
end
