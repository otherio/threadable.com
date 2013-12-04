module Covered

  extend ActiveSupport::Autoload

  CoveredError        = Class.new(StandardError)
  RecordNotFound      = Class.new(CoveredError)
  RecordInvalid       = Class.new(CoveredError)
  CurrentUserNotFound = Class.new(RecordNotFound)
  AuthorizationError  = Class.new(CoveredError)
  AuthenticationError = Class.new(CoveredError)

  # Utilities
  autoload :Config
  autoload :Class
  autoload :CurrentUser
  autoload :Tracker
  autoload :InMemoryTracker
  autoload :MixpanelTracker
  autoload :Emails

  # resources
  autoload :EmailAddresses
  autoload :EmailAddress
  autoload :Users
  autoload :User
  autoload :Projects
  autoload :Project
  autoload :Conversations
  autoload :Conversation
  autoload :Tasks
  autoload :Task
  autoload :Messages
  autoload :Message
  autoload :Attachments
  autoload :Attachment
  autoload :IncomingEmails
  autoload :IncomingEmail
  autoload :Events
  autoload :Event


  # superclasses
  autoload :Mailer
  autoload :Worker

  # procedures
  autoload :ProcessIncomingEmail
  autoload :SignUp

  def self.config name
    Config[name]
  end

  def self.new(*args)
    Covered::Class.new(*args)
  end

  def self.use_relative_model_naming?
    false
  end

end

