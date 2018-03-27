module RidepilotCadAvl
  class API::V1::TripsController < API::V1::BaseController

    def update_fare
      @trip = Trip.find_by_id(params[:id])
      fare = @trip.fare || @trip.provider.fare
      if fare && !fare.is_free?
        if fare.is_payment?
          @trip.fare_amount = params[:amount]
          @trip.fare_collected_time = DateTime.now
          @trip.save(validate: false)
        else
          donation = @trip.donation || @trip.build_donation
          donation.amount = params[:amount]
          donation.date = DateTime.now
          donation.save(validate:false)
        end
      end

      render success_response({})
    end
  end  
end