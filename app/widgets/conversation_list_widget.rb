class ConversationListWidget < Rails::Widget::Presenter

  arguments :organization

  option :conversations do
    organization.conversations.all_with_participants
  end

end
