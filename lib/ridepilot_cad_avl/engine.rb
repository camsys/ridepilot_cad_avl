require 'pg'
require 'simple_token_authentication'
require 'fast_jsonapi'

module RidepilotCadAvl
  class Engine < ::Rails::Engine
    isolate_namespace RidepilotCadAvl
  end
end
