class Covered::IncomingEmails < Covered::Collection

  autoload :Create

  def all
    incoming_emails_for scope.reload
  end

  def find_by_id id
    incoming_email_for (scope.find(id) or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Covered::RecordNotFound, "unable to find incoming email with id #{id.inspect}"
  end

  def create! mailgun_params
    Create.call(self, mailgun_params)
  end

  def inspect
    %(#<#{self.class}>)
  end

  private

  def scope
    ::IncomingEmail.all
  end

  def incoming_email_for incoming_email_record
    Covered::IncomingEmail.new(covered, incoming_email_record)
  end

  def incoming_emails_for incoming_email_records
    incoming_email_records.map{ |incoming_email_record| incoming_email_for incoming_email_record }
  end

end
