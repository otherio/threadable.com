class ComposeConversationMessageModalWidget < Rails::Widget::Presenter

  arguments :project

  classname :modal, :hide, :fade

  option :conversation do
    project.conversations.build
  end

end
