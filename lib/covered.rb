module Covered

  extend ActiveSupport::Autoload

  require 'covered/transactions'
  extend Covered::Transactions

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

end
