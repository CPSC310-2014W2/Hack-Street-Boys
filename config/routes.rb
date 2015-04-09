Rails.application.routes.draw do
  
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get 'weather_search', to: 'weather_search#index'
  
  get 'sessions/create'
  get 'sessions/destroy'
  get 'home/index'
  get 'setting/index'
  get 'setting/update'
  get 'events/index'
  get 'weather_forecast/index'

  get 'test/app_helper_test', to: 'test#app_helper_test'
  get 'test/setting_helper_test', to: 'test#setting_helper_test'
  
  root 'home#index'

  resources :events, only: [:showEvent, :editEvent, :newEvent, :createEvent, :deleteEvent, :updateEvent, :testEvent] do
    get :testEvent, :on => :collection
    get :showEvent, :on => :collection
    get :editEvent, :on => :collection
    get :newEvent, :on => :collection
    post :createEvent, :on => :collection
    post :deleteEvent, :on => :collection
    post :updateEvent, :on => :collection
  end
  resources :fav_cities
  
  resources :weather_forecast, only: [:index] do
      get :index, :on => :collection
  end
  
  resources :sessions, only: [:create, :destroy]
  resources :home, only: [ :test_get_cities_weather, :test_google_latlon, :test_get_city_weather] do
    get :test_google_latlon, :on => :collection
    get :test_get_city_weather, :on => :collection
    get :test_get_cities_weather, :on => :collection
  end
  resources :setting, only: [ :index, :update ]
  resources :weather_search
  
  # The below is for testing only, comment out before deployment
  resources :test, only: [ :app_helper_test, :setting_helper_test ]

end
