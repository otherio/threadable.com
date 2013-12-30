require_dependency 'covered/conversation'

class Covered::Conversation::Recipients

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :covered, to: :conversation

  def all
    user_records = User.
      joins(:organization_memberships).
      where(organization_memberships:{gets_email:true, organization_id: conversation.organization_id})

    if conversation.id.present?
      user_records = user_records.
        joins("LEFT JOIN conversations_muters m ON m.user_id = users.id AND m.conversation_id = #{conversation.id}").
        where('m.user_id IS NULL')
    end

    groups = conversation.groups.all

    if groups.present?
      group_ids = groups.map(&:id).join(',')
      user_records = user_records.
      joins("INNER JOIN group_memberships ON group_memberships.group_id in (#{group_ids})").
      where('group_memberships.user_id = users.id')
    end

    user_records.map{|user_record| Covered::User.new(covered, user_record) }
  end

  def inspect
    %(#<#{self.class} conversation_id: #{conversation.id.inspect}>)
  end

end
