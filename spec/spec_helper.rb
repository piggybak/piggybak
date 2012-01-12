# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start 'rails'

ENV['SKIP_RAILS_ADMIN_INITIALIZER'] = 'true'
require File.expand_path('../dummy_app/config/environment', __FILE__)

require 'rspec/rails'
require 'factory_girl'
require 'factories'
require 'database_helpers'

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
#ActionMailer::Base.default_url_options[:host] = "example.com"

Rails.backtrace_cleaner.remove_silencers!

include DatabaseHelpers
# Run any available migration
puts 'Setting up database...'
drop_all_tables
migrate_database
ENV['SKIP_RAILS_ADMIN_INITIALIZER'] = 'false'
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each{|f| require f}

RSpec.configure do |config|
  require 'rspec/expectations'

  config.include RSpec::Matchers
  config.include DatabaseHelpers
  config.include Piggybak::Engine.routes.url_helpers

  config.before(:each) do
    # RailsAdmin::Config.excluded_models = [RelTest, FieldTest]
    RailsAdmin::AbstractModel.all_models = nil
    RailsAdmin::AbstractModel.all_abstract_models = nil
    RailsAdmin::AbstractModel.new("User").destroy_all!
    RailsAdmin::AbstractModel.new("Category").destroy_all!
    RailsAdmin::AbstractModel.new("Page").destroy_all!
    RailsAdmin::AbstractModel.new("Role").destroy_all!
    RailsAdmin::AbstractModel.new("Image").destroy_all!
  end

  config.after(:each) do
    Piggybak.reset
  end
end
