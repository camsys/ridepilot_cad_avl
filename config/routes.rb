RidepilotCadAvl::Engine.routes.draw do
  get   'cad_avl'         => 'cad#index'
  get   'reload_runs'     => 'cad#reload_runs'
  namespace :api, defaults: { format: :json } do
    namespace :v1 do 
      post  'driver_sign_in'  => 'driver_sessions#create'
      
      get   'runs'            => 'runs#index'
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
