module TestEnvironment::SentEmail

  class Emails < Array

    def join_notices(project_name)
      find_all do |email|
        email.subject == "You've been added to #{project_name}"
      end
    end

    def sent_to(to_address)
      find_all do |email|
        email.to.include?(to_address)
      end
    end

    def find_all
      self.class.new super
    end

  end

  class Email < SimpleDelegator

    def links
      URI.extract(body.to_s)
    end

    def project_unsubscribe_link
      links.find{|link| link =~ %r(/unsubscribe/) }
    end

    def user_setup_link
      links.find{|link| link =~ %r(/setup) }
    end

  end

  def sent_emails
    Emails.new(ActionMailer::Base.deliveries.map{|email| Email.new(email) })
  end

end
