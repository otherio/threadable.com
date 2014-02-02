load File.expand_path('../production.rb', __FILE__)

Threadable::Application.configure do

  config.force_ssl = false

  config.log_level = :debug

  config.action_mailer.smtp_settings.merge!(
    :user_name => 'postmaster@staging.threadable.com',
    :domain => 'staging.threadable.com',
  )

  config.action_controller.default_url_options = { :host => 'staging.threadable.com' }
  config.action_mailer.default_url_options = config.action_controller.default_url_options

  # TODO: should live in a yaml file or ENV or something someday
  config.token_key = 'staging key so there'

end
