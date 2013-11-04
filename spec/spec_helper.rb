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
  config.infer_base_class_for_anonymous_controllers = true
  config.order = "random"

  config.include TestEnvironment
  config.include FindHelpers
  config.include CapybaraEnvironment, :type => :acceptance
  config.include CapybaraEnvironment, :type => :feature

  config.before :suite do
    CapybaraEnvironment.before_suite!
  end

  config.before :each do |spec|
    begin_test_transaction! if use_test_transaction? && spec.example.metadata[:transaction] != false
    ActionMailer::Base.deliveries.clear
    Rails.application.routes.stub(:default_url_options).and_return(Rails.application.routes.default_url_options.try(:dup) || {})
    Rails.configuration.action_controller.stub(:default_url_options).and_return({})
    Rails.configuration.action_mailer.stub(:default_url_options).and_return({})
    Sidekiq.redis{|r| r.flushdb}
    Covered::BackgroundJobs::Worker.jobs.clear
  end

  config.after :each do |spec|
    if test_transaction_open?
      end_test_transaction!
    else
      reload_fixtures!
    end
  end

end
