module RidepilotCadAvl
  class CadController < ::ApplicationController
    layout "ridepilot_cad_avl/application"
    def index
      @provider = current_user.current_provider
      @cad_day = Date.today

      @runs = Run.for_provider(current_provider_id).for_date(@cad_day).reorder("lower(name)")
    end

  end
end
