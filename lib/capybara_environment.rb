require 'test_environment'
require 'capybara'
require 'capybara/dsl'

module CapybaraEnvironment

  include Capybara::DSL
  include TestEnvironment

  Dir[File.expand_path('../capybara_environment/*.rb', __FILE__)].each do |path|
    include "CapybaraEnvironment::#{File.basename(path, '.rb').camelize}".constantize
  end

  def use_test_transaction?
    false
  end

  SELENIUM = ENV['SELENIUM'] == 'true'
  # SELENIUM_BROWSER=safari
  # SELENIUM_BROWSER=chrome
  # SELENIUM_BROWSER=firefox
  SELENIUM_BROWSER = (ENV['SELENIUM_BROWSER'].presence || :chrome).to_sym

  def before_suite!
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app, browser: SELENIUM_BROWSER)
    end

    Capybara.exact_options          = true
    Capybara.ignore_hidden_elements = true
    Capybara.default_driver         = SELENIUM ? :selenium : :webkit
    Capybara.javascript_driver      = SELENIUM ? :selenium : :webkit
    Capybara.default_selector       = :css
    Capybara.default_wait_time      = 5
    Capybara.server_port = Rails.configuration.action_mailer.default_url_options[:port]
    Capybara.server_host = Rails.configuration.action_mailer.default_url_options[:host]
    super
  end

  extend self

end
