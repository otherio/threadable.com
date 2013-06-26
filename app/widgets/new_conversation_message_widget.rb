class NewConversationMessageWidget < Rails::Widget::Presenter

  arguments :conversation

  def new_conversation?
    conversation.new_record?
  end

  html_option 'data-auto_show_right_text' do
    new_conversation?
  end

  option :from do
    @view.current_user
  end

  option :project do
    conversation.project
  end

  option :message do
    conversation.messages.build
  end

  option :url do
    if new_conversation?
      @view.project_conversations_path(project)
    else
      @view.project_conversation_messages_path(project, conversation)
    end
  end

  option :show_subject do
    new_conversation?
  end

  option :autofocus do
    new_conversation?
  end

  option :remote do
    !new_conversation?
  end

end
