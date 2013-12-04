require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups(:assets => %w(development test)))

$:.unshift Bundler.root.join('lib')
require 'rails/console_methods'
require 'covered'

module Covered
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += [
      Rails.root.join('lib'),
      Rails.root.join('app/widgets'),
    ]

    config.i18n.default_locale = :en

    config.assets.precompile += %w{
      init.js
      bootstrap-wysihtml5.css
      bootstrap-wysihtml5.js
      bootstrap-wysihtml5/wysiwyg-color.css
    }


    config.app_generators do |c|
      c.test_framework :rspec, :fixture => true,
                               :fixture_replacement => nil

      c.integration_tool :rspec
      c.performance_tool :rspec
    end

    # sign in is enabled by default, but can be disabled
    config.signup_enabled = ENV["COVERED_SIGNUP_ENABLED"] != "false"

    config.filepicker_rails.api_key = ENV.fetch('COVERED_FILEPICKER_API_KEY')

    config.roadie.enabled = true

    config.force_ssl = false

    config.track_in_memory = false
  end
end

require 'wtf'
require 'ruby_template_handler'
