ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../lib/fix_minitest", __FILE__)
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'rails/widgets/rspec'
require 'capybara_environment'
require 'webmock/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|

  config.use_transactional_fixtures = false

  config.include TestEnvironment
  config.include ResqueUnit::Assertions
  config.include CapybaraEnvironment, :type => :request
  config.include CapybaraEnvironment, :type => :acceptance

  config.before :suite do
    CapybaraEnvironment.before_suite!
  end

  config.before :each do |spec|
    begin_test_transaction! if use_test_transaction? && spec.example.metadata[:transaction] != false
    Resque.reset!
    ActionMailer::Base.deliveries.clear
    Rails.application.routes.stub(:default_url_options).and_return(Rails.application.routes.default_url_options.try(:dup) || {})
    Rails.configuration.action_controller.stub(:default_url_options).and_return({})
    Rails.configuration.action_mailer.stub(:default_url_options).and_return({})
  end

  config.after :each do |spec|
    if test_transaction_open?
      end_test_transaction!
    else
      reload_fixtures!
    end
  end

  config.infer_base_class_for_anonymous_controllers = true

  config.order = "random"

  config.include ControllerAuthenticationHelpers, :type => :controller, :example_group => {
    :file_path => config.escaped_path(%w[spec controllers])
  }

end
