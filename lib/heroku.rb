module Heroku

  def self.redis_config
    if ENV.has_key? "REDISCLOUD_URL"
      {url: ENV["REDISCLOUD_URL"]}
    else
      {}
    end
  end

end
