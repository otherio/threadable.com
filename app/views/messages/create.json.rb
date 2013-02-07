@message.as_json.merge(
  as_html: render_widget(:message, @message)
)
