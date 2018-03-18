RidepilotCadAvl::Engine.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do 
      post  'driver_sign_in'  => 'driver_sessions#create'
      
      get   'runs'            => 'runs#index'
      resources :runs, only: [:index] do
        member do
          put 'start' 
          put 'end' 
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
        end 
      end
    end
  end
end
