class MessageWidget < Rails::Widget::Presenter

  arguments :message

  def init
    @html_options[:shareworthy] = true if message.shareworthy?
    @html_options[:knowledge] = true if message.knowledge?

    locals[:hide_quoted_text] = !message.root? && (message.body_plain != message.stripped_plain)
    locals[:stripped_plain] = htmlify message.stripped_plain
    locals[:body_plain] = htmlify message.body_plain
  end

  def link_to_toggle attribute, &block
    path = @view.project_conversation_message_path(message.conversation.project, message.conversation, message)
    params = {message:{attribute => !message.send("#{attribute}?")}}.to_param
    classname = "#{attribute} control-link"
    @view.link_to(path, remote: true, method: 'put', :"data-params" => params, class: classname, &block)
  end

  private

  def message
    locals[:message]
  end

  def htmlify(message_content)
    @view.send(:h, message_content.strip).gsub(/\s*\n/, "<br/>").html_safe
  end

end
