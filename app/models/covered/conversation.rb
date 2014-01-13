class Covered::Conversation < Covered::Model

  class << self
    alias_method :__new__, :new
    def new covered, conversation_record
      conversation_record.task? ?
        Covered::Task        .__new__(covered, conversation_record) :
        Covered::Conversation.__new__(covered, conversation_record)
    end
  end

  self.model_name = ::Conversation.model_name

  def initialize covered, conversation_record
    @covered, @conversation_record = covered, conversation_record
  end
  attr_reader :conversation_record

  delegate *%w{
    id
    to_param
    slug
    subject
    task?
    messages_count
    organization_id
    creator_id
    created_at
    updated_at
    persisted?
    new_record?
    errors
    muters
  }, to: :conversation_record

  private :muters

  let(:organization){ covered.organizations.find_by_id(organization_id) }
  let(:creator     ){ Creator.new(self) if creator_id }
  let(:events      ){ Events.new(self)       }
  let(:messages    ){ Messages.new(self)     }
  let(:recipients  ){ Recipients.new(self)   }
  let(:participants){ Participants.new(self) }
  let(:groups      ){ Groups.new(self) }


  def mute!
    raise ArgumentError, "covered.current_user is nil" if covered.current_user.nil?
    muters << covered.current_user.user_record
    self
  end

  def unmute!
    raise ArgumentError, "covered.current_user is nil" if covered.current_user.nil?
    muters.delete(covered.current_user.user_record)
    self
  end

  def muted?
    raise ArgumentError, "covered.current_user is nil" if covered.current_user.nil?
    muted_by? covered.current_user
  end

  def muted_by? user
    muters.map(&:id).include?(user.user_id)
  end

  def update attributes
    !!conversation_record.update_attributes(attributes)
  end

  def update! attributes
    update(attributes) or raise Covered::RecordInvalid, "Conversation invalid: #{errors.full_messages.to_sentence}"
  end

  def destroy!
    conversation_record.destroy!
    self
  end

  def participant_names
    messages = self.messages.all
    return [creator.name.split(/\s+/).first] if messages.empty? && creator.present?
    messages.map do |message|
      case
      when message.creator.present?
        message.creator.name.split(/\s+/).first
      else
        ExtractNamesFromEmailAddresses.call([message.from]).first
      end
    end.compact.uniq
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

end
