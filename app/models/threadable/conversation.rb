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
    trashed_at
    persisted?
    new_record?
    last_message_at
    errors
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

  def follower_ids
    conversation_record.follower_ids_cache
  end

  def muter_count
    conversation_record.muter_ids_cache.length
  end

  def follower_count
    recipient_follower_ids.length
  end

  def recipient_follower_ids
    if private?
      group_recipient_ids = conversation_record.groups.eager_load(:members).map(&:members).flatten.map(&:id)
      owner_ids = organization.organization_record.memberships.who_are_owners.map(&:user_id)
      conversation_record.follower_ids_cache & group_recipient_ids + owner_ids
    else
      conversation_record.follower_ids_cache
    end
  end

  def mute_for user
    unless muted_by? user
      Threadable.transaction do
        conversation_record.muters << user.user_record
        unfollow_for user, false
        update_muter_follower_caches!
      end
    end
    self
  end

  def unmute_for user, update_caches = true
    if muted_by? user
      Threadable.transaction do
        conversation_record.muters.delete user.user_record
        update_muter_follower_caches! if update_caches
      end
    end
    self
  end

  def follow_for user
    unless followed_by? user
      Threadable.transaction do
        conversation_record.followers << user.user_record
        unmute_for user, false
        update_muter_follower_caches!
      end
    end
    self
  end

  def unfollow_for user, update_caches = true
    if followed_by? user
      Threadable.transaction do
        conversation_record.followers.delete user.user_record
        update_muter_follower_caches! if update_caches
      end
    end
    self
  end

  def mute!
    ensure_current_user
    mute_for threadable.current_user
    self
  end

  def unmute!
    ensure_current_user
    unmute_for threadable.current_user
    self
  end

  def muted?
    ensure_current_user
    muted_by? threadable.current_user
  end

  def follow!
    ensure_current_user
    follow_for threadable.current_user
    self
  end

  def unfollow!
    ensure_current_user
    unfollow_for threadable.current_user
    self
  end

  def followed?
    ensure_current_user
    followed_by? threadable.current_user
  end

  def muted_by? user
    muter_ids.include?(user.user_id)
  end
  alias_method :muted_by, :muted_by?

  def followed_by? user
    follower_ids.include?(user.user_id)
  end
  alias_method :followed_by, :followed_by?

  def private?
    conversation_record.private_cache
  end

  def private_permitted_user_ids
    user_ids = GroupMembership.
      joins("INNER JOIN conversation_groups ON group_memberships.group_id = conversation_groups.group_id AND conversation_groups.active = \'t\' AND conversation_groups.conversation_id = #{self.id}").
      map(&:user_id)
    (user_ids + organization.owner_ids).uniq
  end

  def sync_to_user recipient
    raise Threadable::AuthorizationError, "You must be a recipient of a conversation to sync it" unless recipients.include? recipient
    messages.not_sent_to(recipient).each do |message|
      message.send_email_for! recipient
    end
  end

  def trash!
    return if trashed?
    Threadable.transaction do
      update(trashed_at: Time.now.utc)
      events.create! :conversation_trashed
      notify_update!
    end
  end

  def untrash!
    return unless trashed?
    Threadable.transaction do
      update(trashed_at: nil)
      events.create! :conversation_untrashed
      notify_update!
    end
  end

  def trashed?
    ! trashed_at.nil?
  end

  def update attributes, notify = false
    if conversation_record.update_attributes(attributes)
      notify_update! if notify
      return true
    end

    false
  end

  def update! attributes
    update(attributes) or raise Threadable::RecordInvalid, "Conversation invalid: #{errors.full_messages.to_sentence}"
  end

  def notify_update!
    update = {
      action: :update,
      target: :conversation,
      target_record: self,
      serializer: :base_conversations,
    }

    update[:user_ids] = private_permitted_user_ids if private?

    organization.application_update(update)
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
    if group.alias_email_address.present?
      return "\"#{name}\" <#{group.alias_email_address_object.address.gsub(/\@/, '.')}>"
    else
      return "\"#{name}\" <#{group.internal_email_address.gsub(/\@/, '.')}>"
    end
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

  def ensure_group_membership!
    return unless self.groups.all == []
    self.groups.add self.organization.groups.primary
  end

  # cache methods

  def update_muter_follower_caches!
    update(muter_ids_cache: conversation_record.muters.map(&:id))
    update(follower_ids_cache: conversation_record.followers.map(&:id))
  end

  def update_group_caches! group_ids=nil
    group_ids ||= groups.all.map(&:id)
    private_count = conversation_record.groups.where(private: true).count
    is_private = private_count > 0 && private_count == group_ids.count
    update(group_ids_cache: group_ids, groups_count: group_ids.size, private_cache: is_private)
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

  private

  def ensure_current_user
    raise ArgumentError, "threadable.current_user is nil" if threadable.current_user.nil?
  end
end
