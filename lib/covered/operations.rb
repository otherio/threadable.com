module Covered::Operations

  extend ActiveSupport::Autoload

  autoload :ProcessIncomingEmail
  autoload :CreateMessageFromIncomingEmail
  autoload :StripUserSpecificContentFromEmailMessageBody

end
