class ConversationMessagesWidget < Widgets::Base

  def init conversation
    locals[:conversation] = conversation
  end

end
