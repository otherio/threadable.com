module Nitrous

  def self.redis_config
    if ENV.has_key? "REDIS_CLOUD_HOST"
      {
        :host => ENV['REDIS_CLOUD_HOST'],
        :port => ENV['REDIS_CLOUD_PORT'],
        :password => ENV['REDIS_CLOUD_PASSWORD']
      }
    else
      {}
    end
  end

end
