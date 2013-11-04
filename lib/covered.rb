require 'wtf'
require 'active_record_read_only'

require 'covered/config'

module Covered

  CoveredError        = Class.new(StandardError)
  RecordNotFound      = Class.new(CoveredError)
  CurrentUserNotFound = Class.new(RecordNotFound)
  AuthorizationError  = Class.new(CoveredError)

  extend ActiveSupport::Autoload

  def self.new(*args)
    Covered::Class.new(*args)
  end

  def self.use_relative_model_naming?
    false
  end

end

require 'covered/class'

