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
    alias_method :to, :sent_to

    def containing content
      find_all do |email|
        email.content.include? content
      end
    end

    def with_subject subject
      find_all do |email|
        email.subject == subject
      end
    end

    def find_all
      self.class.new super
    end

  end

  class Email < SimpleDelegator

    def text_content
      return text_part.try(:body).to_s if multipart?
      return body.to_s if content_type.include? 'text/plain;'
    end

    def html_content
      return html_part.try(:body).try(:to_s) if multipart?
      return body.to_s if content_type.include? 'text/html;'
    end

    def content
      "#{text_content}\n\n\n\n#{html_content}"
    end

    def urls
      URI.extract(content)
    end

    def html
      Nokogiri.parse(html_content.to_s)
    end

    def links text_content=nil
      links = html.css('a[href]')
      links = links.find_all{|link| link.text == text_content } if text_content.present?
      links
    end

    def link text_content
      links(text_content).first
    end

    def project_unsubscribe_url
      urls.find{|url| url =~ %r(/unsubscribe/) }
    end

    def user_setup_url
      urls.find{|url| url =~ %r(/setup) }
    end

  end

  def sent_emails
    Emails.new(ActionMailer::Base.deliveries.map{|email| Email.new(email) })
  end

end
