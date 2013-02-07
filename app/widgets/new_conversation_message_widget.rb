class NewConversationMessageWidget < Widgets::Base

  def init conversation
    locals[:conversation] = conversation
  end

end
