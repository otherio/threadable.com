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

  def reload
    conversation_record.reload
    self
  end

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
  }, to: :conversation_record

  let(:organization){ covered.organizations.find_by_id(organization_id) }
  let(:creator     ){ Creator.new(self) if creator_id }
  let(:events      ){ Events.new(self)       }
  let(:messages    ){ Messages.new(self)     }
  let(:recipients  ){ Recipients.new(self)   }
  let(:participants){ Participants.new(self) }
  let(:groups      ){ Groups.new(self) }

  def mute_for user
    if conversation_record.muters.exclude? user.user_record
      conversation_record.muters << user.user_record
    end
    self
  end

  def unmute_for user
    if conversation_record.muters.include? user.user_record
      conversation_record.muters.delete user.user_record
    end
    self
  end

  def mute!
    raise ArgumentError, "covered.current_user is nil" if covered.current_user.nil?
    mute_for covered.current_user
    self
  end

  def unmute!
    raise ArgumentError, "covered.current_user is nil" if covered.current_user.nil?
    unmute_for covered.current_user
    self
  end

  def muted?
    raise ArgumentError, "covered.current_user is nil" if covered.current_user.nil?
    muted_by? covered.current_user
  end

  def muted_by? user
    !!conversation_record.muters.where(conversations_muters: {:user_id => user.user_id}).exists?
  end
  alias_method :muted_by, :muted_by?

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
    participants = User.all.distinct.joins(:messages).where(messages:{conversation_id:id}).
      select('name, messages.created_at').order('messages.created_at ASC').limit(3).map(&:name)
    participants = [creator.name] if participants.empty? && creator
    participants.map do |participant|
      participant.split(/\s+/).first
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
