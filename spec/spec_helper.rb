ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'capybara_environment'
CapybaraEnvironment.setup!
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|

  config.include TestEnvironment
  config.include CapybaraEnvironment, :type => :request
  config.include CapybaraEnvironment, :type => :acceptance

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false

  config.before do |spec|
    case spec.example.metadata[:type]
    when :request, :acceptance
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end
  config.after do
    DatabaseCleaner.clean
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

end
