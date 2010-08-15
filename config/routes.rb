Pluspanda::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to                  => "marketing#index"
  match 'home'              => 'marketing#index'
  match 'pricing'           => 'marketing#pricing'
  match 'faq'               => 'marketing#faq'
  match 'contact'           => 'marketing#contact'
  match 'terms_of_service'  => 'marketing#terms_of_service'
  match 'privacy_policy'    => 'marketing#privacy_policy'
  
  match 'admin'             => 'admin#index'
  match 'admin/manage'      => 'admin#manage'
  match 'admin/install'     => 'admin#install'
  match 'admin/collect'     => 'admin#collect'
  match 'admin/settings'    => 'admin#settings'
  match 'admin/save_css'    => 'admin#save_css'
  match 'admin/save_positions'    => 'admin#save_positions'
  match 'admin/staging'     => 'admin#staging'
  
  
  resource :user_session do
    get :logout, :on => :member
  end
  
  resource :account, :controller => "users"
  
  resources :testimonials do
    get :widget, :on => :collection
    #get :collect, :on => :collection
  end
  
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
