module Covered

  CoveredError        = Class.new(StandardError)
  RecordNotFound      = Class.new(CoveredError)
  RecordInvalid       = Class.new(CoveredError)
  CurrentUserNotFound = Class.new(RecordNotFound)
  AuthorizationError  = Class.new(CoveredError)
  UserAlreadyAMemberOfProjectError = Class.new(CoveredError)

  extend ActiveSupport::Autoload

  def self.new(*args)
    Covered::Class.new(*args)
  end

  def self.use_relative_model_naming?
    false
  end

end

require 'covered/config'
require 'covered/class'

