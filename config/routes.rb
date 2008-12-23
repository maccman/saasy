ActionController::Routing::Routes.draw do |map|
  # Sessions
  map.logout '/logout', :controller => "sessions", :action => "destroy"
  map.login '/login', :controller => "sessions", :action => "new"
  map.open_id_complete "sessions", :controller => "session", :action => "create", :requirements => { :method => :get }
  map.resource :session
  
  # Users
  map.register '/register', :controller => "users", :action => "new"
  map.signup '/signup',     :controller => "users", :action => "new"
  map.register '/user',     :controller => "users", :action => "show"
  map.register '/activate/:id', :controller => "users", :action => "activate"
  map.resources :users,     
                  :collection => { 
                    :current  => :get,
                    :add_user => [:get, :post]
                  },
                  :member => {
                    :unsuspend => :post
                  }
  map.open_id_complete "users", :controller => "users", :action => "create", :requirements => { :method => :get }
  
  map.resource :billing, :controller => "billing", :collection => { 
    :change_owner => :post, 
    :change_plan  => :post,
    :invoice      => :get,
    :cancel => [:get, :post]
  }
  
  map.resource :subscriptions
  map.resource :subscription_addresses

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "users", :action => "show"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
