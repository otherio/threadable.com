class ConversationMessagesWidget < Rails::Widget::Presenter

  arguments :conversation

  option :from do
    @view.current_user
  end

  option :items do
    messages = conversation.messages.all.map{|m| [:message, m]}
    events   = conversation.events.all.map{|e| [:event, e]}
    (messages + events).sort_by{|i| i.last.created_at }
  end

end
