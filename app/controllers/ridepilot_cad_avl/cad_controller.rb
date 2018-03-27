module RidepilotCadAvl
  class CadController < ApplicationController

    def index
      @provider = current_user.current_provider
      # current_user.current_provider = @provider
      # current_user.save!
    end

  end
end
