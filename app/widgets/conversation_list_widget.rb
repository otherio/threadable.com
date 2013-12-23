class ConversationListWidget < Rails::Widget::Presenter

  arguments :organization

  option :not_muted_conversations do
    organization.conversations.not_muted_with_participants
  end

  option :muted_conversations do
    organization.conversations.muted_with_participants
  end

end
