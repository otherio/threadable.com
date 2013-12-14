module Covered

  extend ActiveSupport::Autoload

  CoveredError        = Class.new(StandardError)
  RecordNotFound      = Class.new(CoveredError)
  RecordInvalid       = Class.new(CoveredError)
  CurrentUserNotFound = Class.new(RecordNotFound)
  AuthorizationError  = Class.new(CoveredError)
  AuthenticationError = Class.new(CoveredError)

  def self.config name
    Covered::Config[name]
  end

  def self.new(*args)
    Covered::Class.new(*args)
  end

  def self.use_relative_model_naming?
    false
  end

  def self.redis
    Sidekiq.redis{|redis|redis}
  end

  def self.postgres
    ActiveRecord::Base.connection
  end

  # this has a significant caveat:
  #   normally redis.get(key) returns the value of the given key
  #   within a multi block reads cannot be made so it returns a Redis::Future
  #   read these docs for more into: https://github.com/redis/redis-rb#futures
  def self.transaction &block
    redis.multi do
      begin
        Rails.logger.info('BEGIN REDIS TRANSACTION')
        postgres.transaction do
          yield
        end
        Rails.logger.info('COMMIT REDIS TRANSACTION')
      rescue Exception
        Rails.logger.info('ABORT REDIS TRANSACTION')
        raise
      end
    end
  end

end
