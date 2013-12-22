class ComposeConversationMessageModalWidget < Rails::Widget::Presenter

  arguments :organization

  classname :modal, :hide, :fade

  option :conversation do
    organization.conversations.build
  end

end
