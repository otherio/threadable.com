class ConversationListWidget < Rails::Widget::Presenter

  arguments :project

  option :conversations do
    project.conversations.includes(:participants)
  end

end
