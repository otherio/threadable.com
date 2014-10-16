class ConversationsSerializer < BaseConversationsSerializer
  def serialize_record conversation
    @doers ||= conversation.task? ? conversation.doers.all : nil
    super.merge!({
      doing:              conversation.task? ? @doers.map(&:user_id).include?(current_user.id) : nil,
      muted:              conversation.muted?,
      followed:           conversation.followed?,
    })
  end
end
