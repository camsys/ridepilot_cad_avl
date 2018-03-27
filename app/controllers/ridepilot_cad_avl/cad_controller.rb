module RidepilotCadAvl
  class CadController < ::ApplicationController
    layout "ridepilot_cad_avl/application"
    def index
      @provider = current_user.current_provider
      @cad_day = Date.today
    end

  end
end
