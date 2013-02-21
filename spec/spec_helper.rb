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

  config.fixture_path = TestEnvironment.fixture_path
  config.use_transactional_fixtures = false

  config.before :suite do
    CapybaraEnvironment.before_suite!
  end

  config.before :each do |spec|
    database_cleaner_start!
  end

  config.after :each do |spec|
    database_cleaner_clean!
  end

  [:request, :acceptance].each do |type|
    config.with_options :type => type do |capybara_specs|

      capybara_specs.include CapybaraEnvironment

      capybara_specs.before do |spec|
        Project.count.should == 2
        ActiveRecord::Base.connection.open_transactions.should == 0
      end

      capybara_specs.after do |spec|
        TestEnvironment::Fixtures.load!
      end

    end
  end

  config.with_options :type => :controller do |controller_specs|
    controller_specs.include Devise::TestHelpers
    controller_specs.before do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end
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
