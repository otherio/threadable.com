Redis.current = Redis.new Rails.application.config.redis

Sidekiq.instance_variable_set(:@redis, nil)
Sidekiq.configure_server do |config|
  config.redis = Rails.application.config.redis
  config.failures_max_count = 5000
end
