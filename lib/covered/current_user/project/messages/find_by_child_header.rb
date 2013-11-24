class Covered::CurrentUser::Project::Messages::FindByChildHeader < MethodObject

  def call project_id, header
    @project_id, @header = project_id, header
    in_reply_to = header['In-Reply-To'].to_s
    references  = header['References'].to_s.split(/\s+/)
    return nil unless in_reply_to.present? || references.present?

    # this fixes a bug in the Eudora mail client (see the JWZ threading algorithm)
    references << in_reply_to if in_reply_to && (in_reply_to != references.last)

    # try the simple query with the most likely parent first
    parent_message = find(references.pop).first and return parent_message

    # try the more complicated query
    potential_parents = find(references)
    references.reverse.each do |reference|
      parent_message = potential_parents.find do |message|
        message.message_id_header == reference
      end
      break if parent_message.present?
    end

    return parent_message
  end

  def find message_id_header
    Message.joins(:conversation => :project).where(
      :projects => { :id => @project_id },
      :messages => { :message_id_header => message_id_header },
    )
  end

end
