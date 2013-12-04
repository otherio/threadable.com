ENV["RAILS_ENV"] ||= 'test'
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factories'
require 'rails/widgets/rspec'
require 'webmock/rspec'
require 'sidekiq/testing'

Sidekiq::Testing.fake!
WebMock.disable_net_connect!(:allow_localhost => true, :allow => "codeclimate.com")

module RSpec::Support; end
Dir[Rails.root.join("spec/support/*.rb")].each {|f| require f}

RSpec.configure do |config|

  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = true
  config.order = "random"

  config.include RSpec::Support::Fixtures
  config.include RSpec::Support::Transactions
  config.include RSpec::Support::Finders
  config.include RSpec::Support::BackgroundJobs
  config.include RSpec::Support::Attachments
  config.include RSpec::Support::IncomingEmailParams
  config.include RSpec::Support::SentEmail

  config.before :each do
    Timecop.return
    ActionMailer::Base.deliveries.clear
    SendEmailWorker.jobs.clear
    Covered::InMemoryTracker.clear
    stub_request(:any, 'https://api.mixpanel.com/track').to_return({ :body => '{"status": 1, "error": null}' })
    stub_request(:any, 'https://api.mixpanel.com/people').to_return({ :body => '{"status": 1, "error": null}' })
    stub_request(:any, 'https://api.mixpanel.com/engage').to_return({ :body => '{"status": 1, "error": null}' })
    stub_request(:any, 'https://api.mixpanel.com/import').to_return({ :body => '{"status": 1, "error": null}' })
  end

  config.around :each do |example|
    use_fixtures    = example.metadata[:fixtures] != false
    use_transaction = example.metadata[:transaction] != false

    ensure_no_open_transactions!

    load_fixtures! if use_fixtures

    if use_transaction
      test_transaction do
        truncate_all_tables! if !use_fixtures
        example.call
      end
    else
      truncate_all_tables! if !use_fixtures
      begin
        example.call
      ensure
        truncate_all_tables!
      end
    end

    ensure_no_open_transactions!
  end

end
