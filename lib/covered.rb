module Covered

  extend ActiveSupport::Autoload

  CoveredError          = Class.new(StandardError)
  RecordNotFound        = Class.new(CoveredError)
  RecordInvalid         = Class.new(CoveredError)
  CurrentUserNotFound   = Class.new(RecordNotFound)
  AuthorizationError    = Class.new(CoveredError)
  AuthenticationError   = Class.new(CoveredError)
  RejectedIncomingEmail = Class.new(CoveredError)

  def self.config name
    Covered::Config[name]
  end

  def self.new(*args)
    Covered::Class.new(*args)
  end

  def self.use_relative_model_naming?
    false
  end

end
