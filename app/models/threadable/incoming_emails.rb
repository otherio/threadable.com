class Threadable::IncomingEmails < Threadable::Collection

  def all
    incoming_emails_for scope.to_a
  end

  def held
    incoming_emails_for scope.where(held: true)
  end

  PAGE_SIZE = 10
  def page page, conditions=nil
    query = scope.reload.limit(PAGE_SIZE).offset(page * PAGE_SIZE).reorder(created_at: :desc)
    query = query.where(conditions) if conditions.present?
    incoming_emails_for query
  end

  def find_by_id id
    incoming_email_for (scope.where(id: id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find incoming email with id #{id.inspect}"
  end

  def latest
    incoming_email_for (scope.last or return)
  end
  alias_method :last, :latest

  def create! mailgun_params
    Create.call(self, mailgun_params)
  end

  def truncate!
    scope.
      where('created_at < ?', 14.days.ago).
      where(held: false, processed: true).
      destroy_all
  end

  def inspect
    %(#<#{self.class}>)
  end

  private

  def scope
    ::IncomingEmail.all
  end

  def incoming_email_for incoming_email_record
    Threadable::IncomingEmail.new(threadable, incoming_email_record)
  end

  def incoming_emails_for incoming_email_records
    incoming_email_records.map{ |incoming_email_record| incoming_email_for incoming_email_record }
  end

end
