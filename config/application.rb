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
require 'roadie_no_external_asset_provider'

module Covered
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += [
      Rails.root.join('lib'),
    ]

    config.i18n.default_locale = :en

    config.assets.precompile += %w{
      FontAwesome.otf
      fontawesome-webfont.eot
      fontawesome-webfont.svg
      fontawesome-webfont.ttf
      fontawesome-webfont.woff
      old.js
      old.css
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
    config.roadie.provider = RoadieNoExternalAssetProvider.new

    config.force_ssl = false

    config.track_in_memory = false
  end
end

require 'extensions'
require 'pp'
require 'wtf'
require 'ruby_template_handler'
require 'run_commands_from_email_message_body'
require 'strip_covered_content_from_email_message_body'
require 'validate_email_address'
require 'prepare_email_subject'
require 'serializer'
require 'extract_email_addresses'
require 'extract_names_from_email_addresses'
require 'filepicker_uploader'
require 'heroku'
require 'mailgun_signature'
require 'storage'
require 'strip_html'
require 'token'
require 'organization_resubscribe_token'
require 'organization_unsubscribe_token'
require 'email_address_confirmation_token'
require 'remember_me_token'
require 'reset_password_token'
require 'unsubscribe_token'
require 'user_setup_token'
require 'email_action_token'
