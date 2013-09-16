module Covered

  extend ActiveSupport::Autoload

  autoload :Operation
  autoload :Config
  autoload :Operations

  def self.config name
    ::Covered::Config[name]
  end

  def self.operation(name)
    define_singleton_method name do |*args, &block|
      const_get("Covered::Operations::#{name.to_s.classify}").call(*args, &block)
    end
  end

  operation :process_incoming_email
  operation :create_message_from_incoming_email
  operation :strip_user_specific_content_from_email_message_body

end
