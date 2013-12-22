class NewConversationMessageWidget < Rails::Widget::Presenter

  arguments :conversation

  def init
    @html_options.add_classname('expanded') if autoexpand
  end

  def new_conversation?
    conversation.new_record?
  end

  option :from do
    @view.current_user
  end

  option :organization do
    conversation.organization
  end

  option :message do
    conversation.messages.build
  end

  option :recipients do
    conversation.recipients.all
  end

  option :url do
    if new_conversation?
      @view.organization_conversations_path(organization, format: :json)
    else
      @view.organization_conversation_messages_path(organization, conversation)
    end
  end

  option :show_subject do
    new_conversation?
  end

  option :autoexpand do
    new_conversation?
  end

  option :autofocus, false

  option :remote do
    !new_conversation?
  end

  html_option 'data-autoexpand' do
    autoexpand
  end

  html_option 'data-autofocus' do
    autofocus
  end

end
