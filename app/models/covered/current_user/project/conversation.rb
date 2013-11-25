class Covered::CurrentUser::Project::Conversation < Covered::Project::Conversation

  extend ActiveSupport::Autoload

  autoload :Creator
  autoload :Events
  autoload :Event
  autoload :CreatedEvent
  autoload :Messages
  autoload :Message
  autoload :Recipients
  autoload :Recipient
  autoload :Participants
  autoload :Participant

  let(:creator     ){ Creator.new(self)      }
  let(:events      ){ Events.new(self)       }
  let(:messages    ){ Messages.new(self)     }
  let(:recipients  ){ Recipients.new(self)   }
  let(:participants){ Participants.new(self) }

end
