Redis.current = Redis.new Rails.application.config.redis

Sidekiq.instance_variable_set(:@redis, nil)
Sidekiq.redis = Rails.application.config.redis
Sidekiq.configure_server do |config|
  config.failures_max_count = 5000
end
