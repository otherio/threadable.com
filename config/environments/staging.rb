load File.expand_path('../production.rb', __FILE__)

Covered::Application.configure do

  config.log_level = :debug

  config.action_mailer.smtp_settings[:user_name] = 'postmaster@staging.covered.io'

  config.action_controller.default_url_options = { :host => 'www-staging.covered.io' }
  config.action_mailer.default_url_options = config.action_controller.default_url_options

  # TODO: should live in a yaml file or ENV or something someday
  config.unsubscribe_token_key = 'staging unsubscribe key so there'

end
