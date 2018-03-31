module RidepilotCadAvl
  class CadController < ::ApplicationController
    layout "ridepilot_cad_avl/application"
    def index
      @provider = current_user.current_provider
      
      @cad_day = if params[:cad] && !params[:cad][:date].blank?
        DateTime.parse params[:cad][:date]
      else
        Date.today
      end

      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
    end

    def reload_runs
      if !params[:selected_day].blank?
        @cad_day = DateTime.parse params[:selected_day]
      end

      if params[:incomplete_runs_only] == "true"
        @runs = Run.for_provider(current_provider_id).for_date(@cad_day).where(complete: [false, nil]).reorder("lower(name)")
      else
        @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
      end

      respond_to do |format|
        format.js
      end

    end

  end
end
