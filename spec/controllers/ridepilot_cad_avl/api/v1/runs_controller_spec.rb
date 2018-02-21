require 'rails_helper'

module RidepilotCadAvl
  RSpec.describe API::V1::RunsController, type: :controller do 
    routes { RidepilotCadAvl::Engine.routes }

    let(:driver_user) { create :user }
    let(:non_driver_user) { create :user }

    let(:headers_reg_valid) { {"X-USER-USERNAME" => driver_user.username, "X-USER-TOKEN" => driver_user.authentication_token} }
    let(:headers_reg_invalid) { {"X-USER-USERNAME" => non_driver_user.username, "X-USER-TOKEN" => non_driver_user.authentication_token} }

    context "runs list" do 
      before do 
        @driver = create(:driver, user: driver_user)
      end

      it "requires driver" do 
        request.headers.merge!(headers_reg_invalid)
        get :index, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns today's runs" do 
        today_run_1 = create(:run, date: Date.today, driver: @driver)
        today_run_2 = create(:run, date: Date.today, driver: @driver)
        tomorrow_run_1 = create(:run, date: Date.tomorrow, driver: @driver)

        request.headers.merge!(headers_reg_valid)
        get :index, format: :json
        expect(assigns(:runs)).to match_array([today_run_1, today_run_2])
      end
    end

    context "manifest" do 
      before do 
        @driver = create(:driver, user: driver_user)
        @complete_run = create(:run, date: Date.today, driver: @driver, complete: true)
        @incomplete_run = create(:run, date: Date.today, driver: @driver)
      end

      it "finds next incomplete run for today" do 
        request.headers.merge!(headers_reg_valid)
        get :manifest, format: :json
        expect(assigns(:run)).to eq(@incomplete_run)
      end
    end
  end

end