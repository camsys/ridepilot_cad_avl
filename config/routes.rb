RidepilotCadAvl::Engine.routes.draw do
  # CAD display page
  get   'cad_avl'         => 'cad#index'
  resource :cad, controller: :cad, only: [] do 
    collection do 
      get 'reload_runs'
      get 'reload_run'
      get 'vehicle_info'
    end
  end

  # APIs for RideAVL
  namespace :api, defaults: { format: :json } do
    namespace :v1 do 
      post  'driver_sign_in'  => 'driver_sessions#create'

      
      get   'runs'            => 'runs#index'
      get   'driver_run_data' => 'runs#driver_run_data'
      resources :runs, only: [:index] do
        member do
          put 'start' 
          put 'end' 
          get 'inspections'
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
