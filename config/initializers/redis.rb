Redis.current = Redis.new Rails.application.config.redis
Resque.redis = Redis.current
