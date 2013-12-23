class MuteConversationLinkWidget < Rails::Widget::Presenter

  arguments :conversation

  node_type :a

  classname 'control-link','text-info'

  html_option :href do
    conversation.muted? ?
      @view.unmute_organization_conversation_path(conversation.organization, conversation) :
      @view.mute_organization_conversation_path(conversation.organization, conversation)
  end

  html_option 'data-method', 'POST'

  option :content do
    conversation.muted? ? 'un-mute conversation' : 'mute conversation'
  end

end
