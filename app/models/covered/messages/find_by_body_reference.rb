class Covered::Messages::FindByBodyReference < MethodObject

  def call organization, body
    body[0..1024] =~ /^-- don't delete this: \[ref: (.*)\]/
    slug = $1

    return nil if slug.blank?

    conversation = organization.conversations.find_by_slug(slug)
    return unless conversation.present?
    message = conversation.messages.latest
    message.message_record if message.present?
  end

end
