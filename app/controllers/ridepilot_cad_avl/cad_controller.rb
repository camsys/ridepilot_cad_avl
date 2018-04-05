module RidepilotCadAvl
  class CadController < ::ApplicationController
    layout "ridepilot_cad_avl/application"

    before_action :get_date

    def index
      @provider = current_user.current_provider
      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
    end

    def reload_runs
      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
      
      if params[:cad] && params[:cad][:incomplete_runs_only] == 'true'
        @runs = @runs.where(end_odometer: nil)
      end

      respond_to :js
    end

    def update_map_markers
      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
      selected_runs = @runs.where(id: params[:cad][:selected_runs])


      respond_to do |format|
        format.js { render locals:{selected_runs: selected_runs} }
      end
    end

    private

    def get_date
      @cad_day = if params[:cad] && !params[:cad][:date].blank?
        DateTime.parse params[:cad][:date]
      else
        Date.today
      end
    end

  end
end
