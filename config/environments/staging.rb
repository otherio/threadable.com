load File.expand_path('../production.rb', __FILE__)

Threadable::Application.configure do

  config.force_ssl = false

  config.log_level = :debug

  config.action_mailer.smtp_settings.merge!(
    :user_name => 'postmaster@threadablestaging.com',
    :password => Threadable.config('mailgun')['password'],
    :domain => 'threadablestaging.com',
    :address => 'smtp.mailgun.org',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  )

  # TODO: should live in a yaml file or ENV or something someday
  config.token_key = 'staging key so there'

  # for scheduled jobs, which have no web request
  config.default_host = 'threadablestaging.com'
  config.default_protocol = 'http'
  config.default_port = 80

  config.realtime = { url: 'https://threadable-staging-realtime.herokuapp.com' }
end
