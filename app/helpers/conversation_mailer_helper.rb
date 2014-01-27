module ConversationMailerHelper
  include EmailHelper

  def email_button content, href, html_options={}
    html_options[:href] = href
    render partial: 'email_button', locals: {
      href: href,
      html_options: html_options,
      content: content,
    }
  end

  def email_action_link conversation, recipient, action
    email_action_url token: EmailActionToken.encrypt(conversation.id, recipient.id, action)
  end

end
