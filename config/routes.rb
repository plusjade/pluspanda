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
  namespace :admin do
    get '/', :action => "index"
    get :widget
    get :manage
    get :testimonials
    get :update
    get :install
    get :collect
    put :settings
    post :save_css
    get :theme_css
    get :theme_stock_css
    get :save_positions
    get :staging
    get :logout
  end 
  
  # account management
  resource :account, :controller => "users"
  resource :session, :controller => "user_sessions"

end
