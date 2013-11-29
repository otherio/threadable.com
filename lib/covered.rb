module Covered

  extend ActiveSupport::Autoload

  CoveredError        = Class.new(StandardError)
  RecordNotFound      = Class.new(CoveredError)
  RecordInvalid       = Class.new(CoveredError)
  CurrentUserNotFound = Class.new(RecordNotFound)
  AuthorizationError  = Class.new(CoveredError)

  # Utilities
  autoload :Config
  autoload :Class
  autoload :CurrentUser

  # resources
  autoload :Users
  autoload :User
  autoload :Projects
  autoload :Project
  autoload :Emails

  # superclasses
  autoload :Mailer
  autoload :Worker

  # procedures
  autoload :ProcessIncomingEmail
  autoload :SignUp

  def self.config name=nil
    Config[name]
  end

  def self.new(*args)
    Covered::Class.new(*args)
  end

  def self.use_relative_model_naming?
    false
  end

end

