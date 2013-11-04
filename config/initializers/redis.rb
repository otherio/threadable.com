Redis.current = Redis.new Rails.application.config.redis
Sidekiq.redis = Rails.application.config.redis
Sidekiq.instance_variable_set(:@redis, nil)

