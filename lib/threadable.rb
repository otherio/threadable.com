module Threadable

  extend ActiveSupport::Autoload

  require 'threadable/transactions'
  extend Threadable::Transactions

  ThreadableError      = Class.new(StandardError)
  RecordNotFound       = Class.new(ThreadableError)
  RecordInvalid        = Class.new(ThreadableError)
  CurrentUserNotFound  = Class.new(RecordNotFound)
  AuthorizationError   = Class.new(ThreadableError)
  AuthenticationError  = Class.new(ThreadableError)
  ExternalServiceError = Class.new(ThreadableError)

  def self.config name
    Threadable::Config[name]
  end

  def self.new(*args)
    Threadable::Class.new(*args)
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

end
