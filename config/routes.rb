Rails.application.routes.draw do
  # legacy api
  resources :testimonials, as: :legacy_testimonials do
    get :widget, :on => :collection, as: :legacy_widget
  end

  # current api
  scope "v1" do
    resources :testimonials do
      # redirect the widget request amazon s3
      # s3 file is the user's themeConfig
      get :widget, :on => :collection, :to => proc {|env|
        apikey = env["QUERY_STRING"].split("=")[1]

        if Rails.env.development?
          user = User.find_by_apikey(apikey)
          # note in development we serve the staged attributes directly
          # even for "published" mode. so we always see staging in published.
          [200, {}, [user.standard_themes.get_staged.generate_theme_config]]
        else
          url = Publish::Config.new(apikey, 'blah').endpoint
          # log    = Rails.root.join('log', 'widget.log')
          # line   = "#{apikey}, #{env["HTTP_REFERER"]}, #{DateTime.now} \n"
          # File.open(log, 'a') { |f| f.write(line) } if File.exist?(log)

          [
            307,
            { 'Location' => url, 'Content-Type' => 'text/html'} ,
            ["redirecting to: #{ url }"]
          ]
        end
      }
    end

  end

  # account management
  resource :account, :controller => "users", :only => [:new, :create] do
    get :reset_password, on: :collection, via: [:get, :post]
  end

  resource :session, :controller => "user_sessions" do
    get "single_access", :on => :member
    get "perishable", :on => :member
  end

  namespace :admin do
    resource :account

    get '/', action: "index"
    get :logout
    get :collect
    get :install
    get :manage
    get :editor
    get :widget
    get :thanks
  end

  resources :users do
    member do
      resources :charges
      put :settings, controller: "api/settings", action: "update"

      scope "/testimonials", controller: "api/testimonials", as: :testimonials do
        get "()", :action => :index
        put "()", :action => :update
        post "/save_positions", :action => :save_positions
      end

      scope "/theme_attributes", :controller => "api/theme_attributes", :as => :theme_attributes, constraints: { attribute: /[\w\-\.]+/ } do
        get "/:attribute/staged" , :action => :staged
        put "/:attribute/staged", :action => :update
        get "/:attribute/original", :action => :original
      end

      scope "/theme", controller: "api/theme", as: :theme do
        post "()", action: :create
        post "/publish", action: :publish
        get "/gallery/:theme", action: :show
        get "/:theme_id/stage", action: :set_staged
      end

      scope "/widget", :controller => 'api/widget', :as => :widget do
        get :staged
        get :published
        get "stock/:theme_name", action: "stock"
      end
    end
  end

  # dashboard
  scope "/pinky", :controller => "pinky", :as => "pinky" do
    get "()" ,:action => "index"
    get "users"
    post "as_user"
  end

  root to: redirect('/admin')
end
