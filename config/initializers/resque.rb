require 'resque/failure/multiple'
require 'resque/failure/redis'

if defined?(Honeybadger)
  Resque::Failure::Honeybadger.configure do |config|
    config.api_key = '505f2518c41866bb0be7ba434bb2b079'
  end
  Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Honeybadger]
  Resque::Failure.backend = Resque::Failure::Multiple
end

Resque.after_fork = Proc.new {
  ActiveRecord::Base.connection.reconnect!
  Redis.current.client.reconnect
}

Resque.queues # this fixed a weird edgecase
