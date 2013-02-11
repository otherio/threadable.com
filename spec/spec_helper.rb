ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'rails/widgets/rspec'
require 'capybara_environment'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}


RSpec.configure do |config|

  config.global_fixtures = :all

  config.include TestEnvironment
  config.include CapybaraEnvironment, :type => :request
  config.include CapybaraEnvironment, :type => :acceptance

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/lib/test_environment/fixtures"
  config.use_transactional_fixtures = false

  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean

  config.before :all do
    CapybaraEnvironment.before_all!
  end

  config.before :each do |spec|
    before_each! spec
    case spec.example.metadata[:type]
    when :request, :acceptance
      config.use_transactional_fixtures = false
    end
  end

  config.after :each do |spec|
    after_each! spec
    config.use_transactional_fixtures = true
  end


  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.with_options :type => :controller do |controller_specs|
    controller_specs.include Devise::TestHelpers
    controller_specs.before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end
  end

end
