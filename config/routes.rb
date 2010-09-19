Pluspanda::Application.routes.draw do
  
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  #root :to                  => "marketing#index"

  # RESTful testimonials API
  resources :testimonials do
    get :widget, :on => :collection
  end
  
  # admin backend  
  match 'admin'                   => 'admin#index'
  match 'admin/manage'            => 'admin#manage'
  match 'admin/install'           => 'admin#install'
  match 'admin/collect'           => 'admin#collect'
  match 'admin/settings'          => 'admin#settings'
  match 'admin/save_css'          => 'admin#save_css'
  match 'admin/theme_css'         => 'admin#theme_css'
  match 'admin/theme_stock_css'   => 'admin#theme_stock_css'
  match 'admin/save_positions'    => 'admin#save_positions'
  match 'admin/staging'           => 'admin#staging'
  match 'admin/logout'            => 'admin#logout'
  
  
  # account management
  resource :account, :controller => "users"
  resource :session, :controller => "user_sessions"
  
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
