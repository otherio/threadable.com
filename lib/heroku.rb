module Heroku

  def self.redis_config
    if ENV.has_key? "REDISCLOUD_URL"
      uri = URI.parse(ENV["REDISCLOUD_URL"])
      {
        :host => uri.host,
        :port => uri.port,
        :password => uri.password
      }
    else
      {}
    end
  end

end
