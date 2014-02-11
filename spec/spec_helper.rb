ENV["RAILS_ENV"] ||= 'test'
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require File.expand_path("../../config/environment", __FILE__)
Rails.application.eager_load!

require 'rspec/rails'
require 'rspec/autorun'
require 'factories'
require 'sidekiq/testing'
require 'shoulda-matchers'
require 'timecop'
require 'timeout'

Sidekiq::Testing.fake!

module RSpec::Support; end
Dir[Rails.root.join("spec/support/*.rb")].each {|f| require f}

RSpec.configure do |config|

  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = true
  config.order = "random"
  config.filter_run_excluding type: "live"
  config.include RSpec::Support::Fixtures
  config.include RSpec::Support::Transactions
  config.include RSpec::Support::Finders
  config.include RSpec::Support::BackgroundJobs
  config.include RSpec::Support::Trackings
  config.include RSpec::Support::Attachments
  config.include RSpec::Support::IncomingEmailParams
  config.include RSpec::Support::SentEmail

  config.before :each do
    Threadable::Transactions.expect_test_transaction = true
    Timecop.return
    Threadable.redis.flushdb
    ActionMailer::Base.deliveries.clear
    clear_background_jobs!
    Threadable::InMemoryTracker.clear
  end

  config.after :all do
    Storage.absolute_local_path.rmtree if Storage.absolute_local_path.exist?
  end

  config.around :each do |example|
    use_fixtures    = example.metadata[:fixtures] != false
    use_transaction = example.metadata[:transaction] != false

    ensure_no_open_transactions!

    load_fixtures! if use_fixtures

    resize_window_to(:large) if defined?(resize_window_to)

    if use_transaction
      test_transaction do
        empty_databases! if !use_fixtures
        example.call
      end
    else
      empty_databases! if !use_fixtures
      begin
        example.call
      ensure
        empty_databases!
      end
    end

    ensure_no_open_transactions!
  end

  if ENV['CIRCLE_ARTIFACTS'].present?
    config.around :each do |example|
      next example.call unless Capybara::DSL === self
      spec_name = Pathname(example.metadata[:example_group_block].source_location.join(':')).relative_path_from(Rails.root).to_s.gsub('/','::')
      `screen-capture start "#{File.join(ENV['CIRCLE_ARTIFACTS'], spec_name)}.webm"`
      begin
        example.call
      ensure
        `screen-capture stop`
      end
    end
  end


end
