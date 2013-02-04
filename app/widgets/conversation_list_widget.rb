class ConversationListWidget < Widgets::Base

  def init conversations
    locals[:conversations] = conversations
  end

end
