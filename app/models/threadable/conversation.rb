class Threadable::Conversation < Threadable::Model

  class << self
    alias_method :__new__, :new
    def new threadable, conversation_record
      conversation_record.task? ?
        Threadable::Task        .__new__(threadable, conversation_record) :
        Threadable::Conversation.__new__(threadable, conversation_record)
    end
  end

  self.model_name = ::Conversation.model_name

  def initialize threadable, conversation_record
    @threadable, @conversation_record = threadable, conversation_record
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
    last_message_at
  }, to: :conversation_record

  attr_writer :organization
  let(:organization){ Threadable::Organization.new(threadable, conversation_record.organization) }
  let(:creator     ){ Creator.new(self) if creator_id }
  let(:events      ){ Events.new(self)       }
  let(:messages    ){ Messages.new(self)     }
  let(:recipients  ){ Recipients.new(self)   }
  let(:participants){ Participants.new(self) }
  let(:groups      ){ Groups.new(self)       }

  def muter_ids
    conversation_record.muter_ids_cache
  end

  def mute_for user
    if conversation_record.muters.exclude? user.user_record
      Threadable.transaction do
        conversation_record.muters << user.user_record
        update_muter_ids_cache!
      end
    end
    self
  end

  def unmute_for user
    if conversation_record.muters.include? user.user_record
      Threadable.transaction do
        conversation_record.muters.delete user.user_record
        update_muter_ids_cache!
      end
    end
    self
  end

  def mute!
    raise ArgumentError, "threadable.current_user is nil" if threadable.current_user.nil?
    mute_for threadable.current_user
    self
  end

  def unmute!
    raise ArgumentError, "threadable.current_user is nil" if threadable.current_user.nil?
    unmute_for threadable.current_user
    self
  end

  def muted?
    raise ArgumentError, "threadable.current_user is nil" if threadable.current_user.nil?
    muted_by? threadable.current_user
  end

  def muted_by? user
    muter_ids.include?(user.user_id)
  end
  alias_method :muted_by, :muted_by?

  def update attributes
    !!conversation_record.update_attributes(attributes)
  end

  def update! attributes
    update(attributes) or raise Threadable::RecordInvalid, "Conversation invalid: #{errors.full_messages.to_sentence}"
  end

  def destroy!
    conversation_record.destroy!
    self
  end

  def convert_to_task!
    Threadable::Task.new threadable, conversation_record.convert_to_task!
  end

  def participant_names
    conversation_record.participant_names_cache
  end

  def message_summary
    conversation_record.message_summary_cache
  end

  def group_ids
    conversation_record.group_ids_cache
  end

  def grouped?
    group_ids.present?
  end

  def formatted_email_addresses
    if grouped?
      return task? ?
        groups.all.map(&:formatted_task_email_address) :
        groups.all.map(&:formatted_email_address)
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
    else
      group = organization.groups.primary
    end
    email_address = Mail::Address.new(group.formatted_email_address)
    name = email_address.display_name || "#{organization.name}: #{group.name}"
    return "\"#{name}\" <#{email_address.address.gsub(/\@/, '.')}>"
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

  def internal_email_address
    if groups.count == 1
      group = groups.all.first
      return task? ? group.internal_task_email_address : group.internal_email_address
    end
    task? ? organization.internal_task_email_address : organization.internal_email_address
  end

  def subject_tag
    subject_tag = "[#{groups.count == 1 ? groups.all.first.subject_tag : organization.subject_tag}]"
    task? ? "[✔\uFE0E]#{subject_tag}" : subject_tag
  end

  def in_primary_group?
    self.groups.all.include? self.organization.groups.primary
  end

  # cache methods

  def update_muter_ids_cache!
    update(muter_ids_cache: conversation_record.muters.map(&:id))
  end

  def update_group_caches! group_ids=nil
    group_ids ||= groups.all.map(&:id)
    update(group_ids_cache: group_ids)
    update(groups_count: group_ids.size)
  end

  def update_message_summary_cache!
    update(message_summary_cache: messages.latest.try(:body_plain).try(:[], 0..50))
  end

  def update_participant_names_cache!
    messages = self.messages.all
    names = messages.map do |message|
      case
      when message.creator.present?
        message.creator.name.split(/\s+/).first
      else
        ExtractNamesFromEmailAddresses.call([message.from]).first
      end
    end.compact.uniq

    if names.empty?
      names = creator.present? ? [creator.name.split(/\s+/).first] : []
    end

    update(participant_names_cache: names)
    conversation_record.reload
  end

  def == other
    self.class === other && other.id == id
  end

  def inspect
    %(#<#{self.class} conversation_id: #{id.inspect}>)
  end

end
