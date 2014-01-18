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

  def email_command_link conversation, subject, command
    organization = conversation.organization
    address = conversation.task? ? organization.task_email_address : organization.email_address
    body = %(-- don't delete this: [ref: #{conversation.slug}]\n)+
           %(-- tip: control covered by putting commands at the top of your reply, just like this:\n\n)+
           %(&#{command})
    mail_to_href address, subject: subject, body: body
  end

end
