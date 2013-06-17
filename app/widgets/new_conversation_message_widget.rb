class NewConversationMessageWidget < Rails::Widget::Presenter

  arguments :conversation

  option :from do
    @view.current_user
  end

end
