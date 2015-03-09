Rails.application.routes.draw do
  
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  
  get 'sessions/create'
  get 'sessions/destroy'
  get 'home/index'
  get 'events/index'
  
  root 'home#index'

  resources :events, only: [:showEvent, :editEvent, :newEvent, :createEvent, :deleteEvent, :updateEvent] do
    get :showEvent, :on => :collection
    get :editEvent, :on => :collection
    get :newEvent, :on => :collection
    post :createEvent, :on => :collection
    post :deleteEvent, :on => :collection
    post :updateEvent, :on => :collection
  end
  resources :fav_cities
  resources :sessions, only: [:create, :destroy]
  resources :home, only: [:test_google_latlon, :test_current_weather, :test_store_weather_data] do
    get :test_google_latlon, :on => :collection
    get :test_current_weather, :on => :collection
    get :test_store_weather_data, :on => :collection
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
