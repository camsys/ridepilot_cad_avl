require 'rails_helper'

module RidepilotCadAvl
  RSpec.describe API::V1::DriverSessionsController, type: :controller do 
    routes { RidepilotCadAvl::Engine.routes }

    let(:driver_user) { create :user }
    let(:non_driver_user) { create :user }

    context "driver signs in/out" do

      it 'requires password for sign in' do
        pw = "somerandombadpw"
        post :create, format: :json, params: { user: { username: driver_user.username, password: pw } }
        
        expect(response).to have_http_status(:unauthorized)
      end


      it 'validates driver role for sign in' do
        pw = attributes_for(:user)[:password]
        post :create, format: :json, params: { user: { username: non_driver_user.username, password: pw } }
        
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'signs in an existing driver' do
        driver = create(:driver, user: driver_user)
        
        pw = attributes_for(:user)[:password]
        post :create, format: :json, params: { user: { username: driver_user.username, password: pw } }
        
        expect(response).to be_success
        
        parsed_response = JSON.parse(response.body)
        
        # Expect a session hash with an username and auth token
        expect(parsed_response["data"]["session"]["username"]).to eq(driver_user.username)
        expect(parsed_response["data"]["session"]["authentication_token"]).to eq(driver_user.authentication_token)  
      end
      
    end
  end
end