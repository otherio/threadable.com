Rails.application.config.after_initialize do
  ActiveRecord::Base.connection_pool.disconnect!

  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] or raise "no database configuration for #{Rails.env}\n#{ActiveRecord::Base.configurations.inspect}"
    config['pool'] = Integer(ENV['DB_POOL']) if ENV['DB_POOL'].present?
    ActiveRecord::Base.establish_connection(config)
  end
end
