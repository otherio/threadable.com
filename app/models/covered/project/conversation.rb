class Covered::Project::Conversation

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

  include Let

  def initialize project, conversation_record
    @project, @conversation_record = project, conversation_record
  end
  attr_reader :project, :conversation_record
  delegate :covered, to: :project

  delegate *%w{
    id
    to_param
    slug
    subject
    task?
    creator_id
    created_at
    updated_at
    persisted?
    new_record?
    errors
  }, to: :conversation_record

  let(:creator     ){ Creator.new(self)      }
  let(:events      ){ Events.new(self)       }
  let(:messages    ){ Messages.new(self)     }
  let(:recipients  ){ Recipients.new(self)   }
  let(:participants){ Participants.new(self) }

  def update attributes
    !!conversation_record.update_attributes(attributes)
  end

  def update! attributes
    update(attributes) or raise Covered::RecordInvalid, "Conversation invalid: #{errors.full_messages.to_sentence}"
  end

  def as_json options=nil
    {
      id:         id,
      param:      to_param,
      slug:       slug,
      task:       task?,
      created_at: created_at,
      updated_at: updated_at,
    }
  end

  def == other
    self.class === other && other.id == id
  end

  def inspect
    %(#<#{self.class} conversation_id: #{id.inspect}>)
  end

  def == other
    self.class === other && other.id == id
  end
end
