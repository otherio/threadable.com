Resque.after_fork = Proc.new { ActiveRecord::Base.connection.reconnect! }
unless ENV.has_key? "REDISCLOUD_URL"
  raise "missing rediscloud url"
end
Resque.queues # this fixed a weird edgecase
