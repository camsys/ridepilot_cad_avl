$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ridepilot_cad_avl/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ridepilot_cad_avl"
  s.version     = RidepilotCadAvl::VERSION
  s.authors     = ["Xudong Liu"]
  s.email       = ["xudong.camsys@gmail.com"]
  s.homepage    = ""
  s.summary     = "RidePilot CAD/AVL module"
  s.description = "Provide CAD/AVL functionalities for RidePilot application, interacting with RidePilot Driver App."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 5.2.0"
  s.add_dependency "pg"
  s.add_dependency "fast_jsonapi"

  s.add_development_dependency 'devise'
  s.add_development_dependency 'simple_token_authentication', '~> 1.0'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'faker'
end
