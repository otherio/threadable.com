Multify::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # this is until we actually deploy something
  # disabled so email can maybe work
  # config.middleware.insert_after(::Rack::Lock, "::Rack::Auth::Basic", "Staging") do |u, p|
  #   [u, p] == ['multify', ENV['MULTIFY_PASSWORD']]
  # end

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
  config.action_mailer.delivery_method = :smtp
  # config.action_mailer.default_charset = "utf-8"
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    :user_name => 'postmaster@multifyapp.com',
    :password => Multify.config('mailgun')['password'],
    :domain => 'multifyapp.com',
    :address => 'smtp.mailgun.org',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }

  config.action_controller.default_url_options = { :host => 'beta.multifyapp.com' }
  config.action_mailer.default_url_options = config.action_controller.default_url_options

  # TODO: should live in a yaml file or ENV or something someday
  config.unsubscribe_token_key = 'correct horse staple production key frobozz wtf bagel'

  config.storage = {
    s3_access_key_id:     ENV['MULTIFY_S3_ACCESS_KEY_ID'],
    s3_secret_access_key: ENV['MULTIFY_S3_SECRET_ACCESS_KEY'],
    bucket_name:          ENV['MULTIFY_S3_BUCKET_NAME'],
  }


  config.redis = Heroku.redis_config

end
