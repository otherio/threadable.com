require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Covered

  @config = {}
  def self.config name
    @config[name.to_sym] ||= begin
      config = Rails.root.join("config/#{name}.yml").read
      config = ERB.new(config).result
      config = YAML.load(config)
      config.has_key?(Rails.env) ? config[Rails.env] : config
    end
  end

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

    # login is enabled by default, but can be disabled
    config.login_enabled = ENV["COVERED_DISABLE_LOGIN"] ? false : true

    config.filepicker_rails.api_key = ENV['COVERED_FILEPICKER_API_KEY']

    config.redis = Redis.current.client.instance_variable_get(:@options).slice(:scheme, :host, :port, :path, :password, :db)
  end
end

require 'wtf'
require 'active_record_read_only'
require 'ruby_template_handler'
