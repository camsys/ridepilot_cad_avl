Rails.application.routes.draw do
  devise_for :users
  mount RidepilotCadAvl::Engine => "/ridepilot_cad_avl"
end
