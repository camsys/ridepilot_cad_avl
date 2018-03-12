RidepilotCadAvl::Engine.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do 
      post  'driver_sign_in'  => 'driver_sessions#create'
      get   'runs'            => 'runs#index'
      get   'manifest'        => 'itineraries#index'
      get   'itinerary'       => 'itineraries#show'
      put   'updateItinStatus' => 'itineraries#updateStatus'
    end
  end
end
