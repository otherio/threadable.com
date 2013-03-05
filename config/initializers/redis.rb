if ENV.has_key? "REDISCLOUD_URL"
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  Redis.current = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  Resque.redis = Redis.current
end
