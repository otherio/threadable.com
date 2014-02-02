ENV["RAILS_ENV"] ||= 'test'
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require File.expand_path("../../config/environment", __FILE__)
Rails.application.eager_load!

require 'rspec/rails'
require 'rspec/autorun'
require 'factories'
require 'webmock/rspec'
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
    Storage.absolute_local_path.rmtree if Storage.absolute_local_path.exist?
    Timecop.return
    Threadable.redis.flushdb
    WebMock.disable_net_connect!(:allow_localhost => true, :allow => "codeclimate.com")
    ActionMailer::Base.deliveries.clear
    clear_background_jobs!
    Threadable::InMemoryTracker.clear
    stub_mixpanel!
  end

  config.around :each do |example|
    use_fixtures    = example.metadata[:fixtures] != false
    use_transaction = example.metadata[:transaction] != false

    ensure_no_open_transactions!

    load_fixtures! if use_fixtures

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

end
