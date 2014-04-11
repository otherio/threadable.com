class Threadable::Messages::FindByChildHeader < MethodObject

  def call organization_id, header
    @organization_id, @header = organization_id, header
    in_reply_to  = header['In-Reply-To'].to_s
    references   = header['References'].to_s.split(/\s+/)
    message_headers = Hash[JSON.parse(header['message-headers'])]
    thread_index = message_headers['Thread-Index'].to_s if message_headers

    # this fixes a bug in the Eudora mail client (see the JWZ threading algorithm)
    references.push(in_reply_to) if in_reply_to.present?
    references.reverse!
    return nil unless references.present? || thread_index.present?

    messages = Message.joins(:conversation => :organization).where(
      :organizations => { :id => organization_id },
      :messages => { :message_id_header => references },
    ).to_a

    references.each do |message_id_header|
      messages.each do |message|
        return message if message.message_id_header == message_id_header
      end
    end

    thread_indices = past_thread_indices(Base64.decode64(thread_index))
    return nil unless thread_indices.present?

    messages = Message.joins(:conversation => :organization).where(
      :organizations => { :id => @organization_id },
      :messages => { :thread_index_header => thread_indices },
    ).to_a

    thread_indices.each do |thread_index_header|
      messages.each do |message|
        return message if message.thread_index_header == thread_index_header
      end
    end

    return nil
  end

  private

  def past_thread_indices thread_index_decoded
    previous_thread_index = thread_index_decoded[0..-6]

    if previous_thread_index.length > 27
      return [Base64.strict_encode64(previous_thread_index)] + past_thread_indices(previous_thread_index)
    end

    return [Base64.strict_encode64(previous_thread_index)]
  end

end
