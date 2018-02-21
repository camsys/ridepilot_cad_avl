require 'pg'
require 'simple_token_authentication'

module RidepilotCadAvl
  class Engine < ::Rails::Engine
    isolate_namespace RidepilotCadAvl
  end
end
