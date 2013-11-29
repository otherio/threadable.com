class ConversationListWidget < Rails::Widget::Presenter

  arguments :project

  option :conversations do
    project.conversations.all_with_participants
  end

end
