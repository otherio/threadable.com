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

  def muter_ids
    conversation_record.muter_ids_cache
  end

  def mute_for user
    if conversation_record.muters.exclude? user.user_record
      Covered.transaction do
        conversation_record.muters << user.user_record
        cache_muter_ids!
      end
    end
    self
  end

  def unmute_for user
    if conversation_record.muters.include? user.user_record
      Covered.transaction do
        conversation_record.muters.delete user.user_record
        cache_muter_ids!
      end
    end
    self
  end

  def cache_muter_ids!
    update(muter_ids_cache: conversation_record.muters.map(&:id))
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
    muter_ids.include?(user.user_id)
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
    conversation_record.participant_names_cache
  end

  def cache_participant_names!
    messages = self.messages.all
    names = messages.map do |message|
      case
      when message.creator.present?
        message.creator.name.split(/\s+/).first
      else
        ExtractNamesFromEmailAddresses.call([message.from]).first
      end
    end.compact.uniq
    names ||= creator.present? ? [creator.name.split(/\s+/).first] : []
    update(participant_names_cache: names)
    conversation_record.reload
  end

  def message_summary
    conversation_record.message_summary_cache
  end

  def cache_message_summary!
    update(message_summary_cache: messages.latest.try(:body_plain).try(:[], 0..50))
  end

  def group_ids
    conversation_record.group_ids_cache
  end

  def cache_group_ids!
    update(group_ids_cache: groups.all.map(&:id))
  end

  def formatted_email_addresses
    if groups.count > 0
      if task?
        return groups.all.map(&:formatted_task_email_address)
      end

      return groups.all.map(&:formatted_email_address)
    end

    [task? ? organization.formatted_task_email_address : organization.formatted_email_address]
  end

  def email_addresses
    formatted_email_addresses.map{ |email| ExtractEmailAddresses.call(email) }.flatten
  end

  def all_email_addresses
    [formatted_email_addresses, email_addresses].flatten
  end

  def canonical_email_address
    ExtractEmailAddresses.call(canonical_formatted_email_address).first
  end

  def list_id
    if groups.count == 1
      group = groups.all.first
      return "\"#{organization.name}: #{group.name}\" <#{organization.email_address_username}+#{group.email_address_tag}.#{covered.email_host}>"
    end
    organization.list_id
  end

  def canonical_formatted_email_address
    if groups.count == 1
      return formatted_email_addresses.first
    end
    task? ? organization.formatted_task_email_address : organization.formatted_email_address
  end

  def list_post_email_address
    if groups.count == 1
      return groups.all.first.email_address
    end
    organization.email_address
  end

  def subject_tag
    subject_tag = "[#{groups.count == 1 ? groups.all.first.subject_tag : organization.subject_tag}]"
    task? ? "[✔\uFE0E]#{subject_tag}" : subject_tag
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
