class ConversationMessagesWidget < Rails::Widget::Presenter

  arguments :conversation

  options :from

  local :items do
    messages = conversation.messages.map{|m| [:message, m]}
    events   = conversation.events.map{|e| [:event, e]}
    (messages + events).sort_by{|i| i.last.created_at }
  end

  private

  def conversation
    locals[:conversation]
  end

end
