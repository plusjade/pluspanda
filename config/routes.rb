Pluspanda::Application.routes.draw do
  
  # legacy api
  resources :testimonials do
    get :widget, :on => :collection
  end
  
  # current api
  scope "v1" do
    resources :testimonials do
      get :widget, :on => :collection, :to => proc {|env|
        apikey = env["QUERY_STRING"].split("=")[1]
                
        if Rails.env.development?
          user = User.find_by_apikey(apikey)
          [200, {}, [user.generate_theme_config]]
        else
          url    = Storage.new(apikey).theme_config_url
          log    = Rails.root.join('log', 'widget.log')
          line   = "#{apikey}, #{env["HTTP_REFERER"]}, #{DateTime.now} \n"
          File.open(log, 'a') { |f| f.write(line) } if File.exist?(log)
          
          [307, {'Location' => url, 'Content-Type' => 'text/html'}, ["redirecting to: #{url}"]]
        end
      }
      get :widget, :on => :collection
    end
  end
  
  # admin
  scope "/admin", :controller => :admin, :as => :admin do
    get '/', :action => "index"
    get :widget
    get :manage
    get :install
    get :collect
    get :staged
    get :published
    get :purchase, :controller => "purchase", :action => "index"
    get :thanks, :controller => "purchase", :action => "thanks"
    
    scope "/testimonials", :as => :testimonials do
      get "()"                  ,:action => :testimonials
      get "/update"             ,:action => :update   
      get "/save_positions"     ,:action => :save_positions
    end

    scope "/theme", :controller => :theme, :as => :theme do
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
  scope "/admin/twitter", :controller => "twitter", :as => "twitter" do
    get '/', :action => "index"
    get :widget
    get :manage
    get :install
    get :collect
    get :staged
    get :published
    put :settings

    scope "/tweets", :as => "tweets" do
      get "()"                  ,:action => :testimonials
      get "/update"             ,:action => :update   
      get "/save_positions"     ,:action => :save_positions
    end

    scope "/theme", :controller => :theme, :as => :theme do
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
  
  
  # account management
  resource :account, :controller => "users"
  resource :session, :controller => "user_sessions" do
    get "single_access", :on => :member
  end

  # dashboard
  scope "/pinky", :controller => "pinky", :as => "pinky" do
    get "()" ,:action => "index"
    get "users"
    post "as_user"
  end
  
end
