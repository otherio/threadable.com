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

  def self.transaction &block
    redis.multi do
      Rails.logger.info('BEGIN REDIS TRANSACTION')
      ActiveRecord::Base.transaction do
        yield
      end
      Rails.logger.info('COMMIT REDIS TRANSACTION')
    end
  rescue Exception
    Rails.logger.info('ABORT REDIS TRANSACTION')
    raise
  end

end
