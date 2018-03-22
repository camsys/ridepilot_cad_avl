require 'pg'
require 'simple_token_authentication'
require 'fast_jsonapi'

module RidepilotCadAvl
  class Engine < ::Rails::Engine
    isolate_namespace RidepilotCadAvl

    # Append migrations from the engine into the main app
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
