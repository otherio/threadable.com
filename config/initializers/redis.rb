if ENV.has_key? "REDISCLOUD_URL"
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  Resque.redis = $redis
end
