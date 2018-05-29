RidepilotCadAvl::Engine.routes.draw do
  # CAD display page
  get   'cad_avl'         => 'cad#index'
  resource :cad, controller: :cad, only: [] do 
    collection do 
      get 'reload_runs'
      get 'reload_run'
      get 'load_run_stops'
      get 'load_prior_path'
      get 'load_upcoming_path'
      get 'vehicle_info'
      get 'past_location_info'
      get 'stop_info'
      get 'expand_run'
      get 'zoom_to_run'
    end
  end

  # APIs for RideAVL
  namespace :api, defaults: { format: :json } do
    namespace :v1 do 
      post  'driver_sign_in'  => 'driver_sessions#create'
      post  'send_emergency_alert'  => 'messages#create_emergency_alert'

      
      get   'runs'            => 'runs#index'
      get   'driver_run_data' => 'runs#driver_run_data'
      resources :runs, only: [:index, :show] do
        member do
          put 'start' 
          put 'end' 
          put 'update_from_address' 
          put 'update_to_address' 
          get 'inspections'
          get 'manifest_published_at'
        end 
      end

      get   'manifest'        => 'itineraries#index'
      resources :itineraries, only: [:index, :show, :update] do
        member do
          put 'depart' 
          put 'arrive'
          put 'pickup'
          put 'dropoff'
          put 'noshow' 
          put 'undo'
          put 'track_location'
          put 'update_eta'
        end 
      end

      resources :trips, only: [] do
        member do 
          put 'update_fare'
        end
      end
    end
  end
end
