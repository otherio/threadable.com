class MessageWidget < Rails::Widget::Presenter

  arguments :message

  html_option :shareworthy do
    true if message.shareworthy?
  end

  html_option :id do
    "message-#{message.id}"
  end

  html_option :knowledge do
    true if message.knowledge?
  end

  def link_to_toggle attribute, &block
    path = @view.project_conversation_message_path(message.conversation.project, message.conversation, message)
    params = {message:{attribute => !message.send("#{attribute}?")}}.to_param
    classname = "#{attribute} control-link"
    @view.link_to(path, remote: true, method: 'put', :"data-params" => params, class: classname, &block)
  end

end
