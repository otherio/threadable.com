require 'test_environment'
require 'capybara'
require 'capybara/dsl'
require 'patches/capybara'

module CapybaraEnvironment

  include Capybara::DSL
  include TestEnvironment

  Dir[File.expand_path('../capybara_environment/*.rb', __FILE__)].each do |path|
    include "CapybaraEnvironment::#{File.basename(path, '.rb').camelize}".constantize
  end

  def database_cleaner_strategy
    :truncation
  end

  def before_suite!
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome)
    end

    Capybara.ignore_hidden_elements = true
    Capybara.default_driver         = ENV['MULTIFY_SELENIUM'] == 'true' ? :selenium : :webkit
    Capybara.javascript_driver      = :selenium
    Capybara.default_selector       = :css
    Capybara.default_wait_time      = 5
    super
  end

  extend self

end
