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

  option :hide_quoted_text do
    !message.root? && (message.body_plain != message.stripped_plain)
  end

  option :stripped_plain do
    auto_link htmlify message.stripped_plain
  end

  option :body_plain do
    auto_link htmlify message.body_plain
  end

  option :stripped_html do
    auto_link clean_html message.stripped_html
  end

  option :body_html do
    auto_link clean_html message.body_html
  end


  def link_to_toggle attribute, &block
    path = @view.project_conversation_message_path(message.conversation.project, message.conversation, message)
    params = {message:{attribute => !message.send("#{attribute}?")}}.to_param
    classname = "#{attribute} control-link"
    @view.link_to(path, remote: true, method: 'put', :"data-params" => params, class: classname, &block)
  end

  private

  def htmlify(message_content)
    @view.send(:h, clean_html(message_content)).gsub(/\s*\n/, "<br/>").html_safe
  end

  def clean_html(html)
    return nil if html.nil?
    Sanitize.clean(html, Sanitize::Config::RELAXED).html_safe
  end

  def auto_link(text)
    @view.send(:auto_link, text)
  end

end
