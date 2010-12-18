Pluspanda::Application.routes.draw do
  
  # legacy api
  resources :testimonials do
    get :widget, :on => :collection
  end
  
  # current api
  scope "v1" do
    resources :testimonials do
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
    get :staging
    
    scope "/testimonials", :as => :testimonials do
      get "()"                  ,:action => :testimonials
      get "/update"             ,:action => :update   
      get "/save_positions"     ,:action => :save_positions
    end

    get "/theme/new"      => "theme#new"
    post "/theme"         => "theme#create"
    get "/theme/publish"  => "theme#publish"
    scope "/theme/:attribute", :controller => :theme, :as => :theme do
      get "()"          ,:action => :staged
      post "()"         ,:action => :update
      get "/original"   ,:action => :original
    end
    
    put :settings
    
    get :logout
  end 
  
  # account management
  resource :account, :controller => "users"
  resource :session, :controller => "user_sessions"

  # dashboard
  scope "/pinky", :controller => "pinky" do
    get "()" ,:action => "index"
    get "users"
  end
  
  # log
  match "/log/:apikey", :to => proc {|env|
    params  = env["action_dispatch.request.path_parameters"]
    log     = Rails.root.join('log', 'widget.log')
    line    = "#{params[:apikey]}, #{env["QUERY_STRING"]}, #{DateTime.now} \n"
    File.open(log, 'a') { |f| f.write(line) } if File.exist?(log)
    [204, {}, []]
  }

    
end
