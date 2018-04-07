module RidepilotCadAvl
  class API::V1::TripsController < API::V1::BaseController

    def update_fare
      @trip = Trip.find_by_id(params[:id])
      fare = @trip.fare || @trip.provider.fare.try(:dup)
      if fare && !fare.is_free?
        @trip.fare_collected_time = DateTime.now
        if fare.is_payment?
          @trip.fare_amount = params[:fare_amount]
          @trip.save(validate: false)
        else
          donation = @trip.donation || @trip.build_donation
          donation.customer = @trip.customer 
          donation.user = current_user
          donation.amount = params[:fare_amount]
          donation.date = DateTime.now
          donation.save(validate:false) if donation.amount && donation.amount > 0
        end

        @trip.fare = fare 
        @trip.save(validate: false) if @trip.changed?
      end

      render success_response({})
    end
  end  
end