require_dependency 'threadable/message'

class Threadable::Message::Recipients < Threadable::Conversation::Recipients

  def initialize message
    @message = message
  end
  attr_reader :message, :conversation

  delegate *%w{
    threadable
    conversation
  }, to: :message

  delegate :organization, to: :conversation

  private

  def scope
    if message.parent_message.nil?
      group_ids = conversation.groups.all.map(&:id)

      if conversation.private?
        owner_ids = organization.organization_record.memberships.who_are_owners.map(&:user_id)
        scope_without_groups.in_groups_with_each_message_including_member_followers(conversation.id, group_ids, owner_ids, true)
      else
        scope_without_groups.in_groups_with_each_message_including_followers(conversation.id, group_ids, true)
      end
    else
      super
    end
  end

end
