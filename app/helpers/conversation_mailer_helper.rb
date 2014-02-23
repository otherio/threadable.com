module ConversationMailerHelper
  include EmailHelper

  def email_button content, href, html_options={}
    html_options[:href] = href
    render partial: 'conversation_mailer/email_button', locals: {
      href: href,
      html_options: html_options,
      content: content,
    }
  end

end
