class Covered::IncomingEmails::Create < MethodObject

  include Let

  def call incoming_emails, params
    @incoming_emails = incoming_emails
    @covered         = incoming_emails.covered
    @params          = params

    if project.nil?
      raise Covered::RejectedIncomingEmail, 'project not found'
    end

    if !member? && !reply?
      raise Covered::RejectedIncomingEmail, 'cannot start conversation. sender is not a member of the project'
    end

    incoming_email_record = ::IncomingEmail.create!(
      params: params,
      project_id: project.id,
      creator_id: sender.try(:id),
    )

    ProcessIncomingEmailWorker.perform_async(@covered.env, incoming_email_record.id)

    return Covered::IncomingEmail.new(@covered, incoming_email_record)

  rescue ActiveRecord::RecordInvalid => e
    raise Covered::RecordInvalid, e.message
  end

  let :project do
    @covered.projects.find_by_email_address @params['recipient']
  end

  let :senders do
    @covered.users.find_by_email_addresses(from_email_addresses)
  end

  let :sender do
    senders.find{|user| @member = project.members.include?(user) } or senders.first
  end

  def member?
    sender && @member
  end

  def reply?
    @is_reply ||= project.messages.find_by_child_message_header(@params).present?
  end

  let :from_email_addresses do
    email_addresses = @params.values_at(*%w{from X-Envelope-From sender}).compact
    Mail::AddressList.new(email_addresses.join(', ')).addresses.map(&:address)
  end

end
