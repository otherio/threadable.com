class Threadable::Messages::FindByChildHeader < MethodObject

  def call organization_id, header
    @organization_id, @header = organization_id, header
    in_reply_to = header['In-Reply-To'].to_s
    references  = header['References'].to_s.split(/\s+/)
    # this fixes a bug in the Eudora mail client (see the JWZ threading algorithm)
    references.push(in_reply_to) if in_reply_to.present?
    references.reverse!
    return nil unless references.present?

    messages = Message.joins(:conversation => :organization).where(
      :organizations => { :id => organization_id },
      :messages => { :message_id_header => references },
    ).to_a

    references.each do |message_id_header|
      messages.each do |message|
        return message if message.message_id_header == message_id_header
      end
    end

    return nil
  end

end
