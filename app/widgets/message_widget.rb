class MessageWidget < Rails::Widget::Presenter

  arguments :message, :index

  local :first_message do
    index == 0
  end

  def initialize *a
    super
    @html_options[:shareworthy] = true if message.shareworthy?
    @html_options[:knowledge] = true if message.knowledge?
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

  def index
    locals[:index]
  end

end
