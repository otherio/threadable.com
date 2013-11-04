Redis.current = Redis.new Rails.application.config.redis
Sidekiq.redis = { url: Redis.current.client.id }


