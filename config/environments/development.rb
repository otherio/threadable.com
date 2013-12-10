Covered::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load


  # Our Customizations

  if ENV['GMAIL'] == 'true'
    config.action_mailer.smtp_settings = {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :domain               => 'covered.io',
      :user_name            => 'coveredthrowaway1@gmail.com',
      :password             => 'coveredcovered',
      :authentication       => 'plain',
      :enable_starttls_auto => true
    }
  else
    config.action_mailer.smtp_settings = {
      :domain => 'covered.io',
      :address => 'localhost',
      :port => 1025
    }
  end

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false

  # enables the load of javascript specs
  config.assets.paths << Rails.root.join("spec", "javascripts")

  config.token_key = 'dev key'

  config.storage = {local:'development'}

  config.redis = ENV["REDIS_CLOUD_HOST"] ? Nitrous.redis_config : { url: 'redis://127.0.0.1:6379/1' }

  config.track_in_memory = true
end
