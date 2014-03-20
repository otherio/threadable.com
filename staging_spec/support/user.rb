class User

  def uuid
    @uuid ||= rand(1_000_000)
  end

  def name
    "TestUser #{uuid}"
  end

  def email_address
    "threadable.staging.test.user.#{uuid}@threadable.com"
  end

  def password
    uuid
  end

  def inbox
    @inbox ||= Inbox.new(self)
  end

  def check_email! timeout=60.seconds
    start_time = Time.now
    start_count = inbox.size
    check_email until inbox.size > start_count || Time.now - start_time > timeout
    inbox.size > start_count
  end

end
