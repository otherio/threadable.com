module RSpec::Support::SentEmail

  class Emails < Array

    def clear
      super
      ActionMailer::Base.deliveries.clear
    end

    def join_notices(organization_name)
      with_subject("You've been added to #{organization_name}")
    end

    def sent_to(to_address)
      find_all do |email|
        (email.smtp_envelope_to + email.to).include?(to_address.to_s)
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
        case subject
        when Regexp; email.subject =~ subject
        else;        email.subject == subject
        end
      end
    end

    def find_all
      self.class.new super
    end

  end

  class Email

    def initialize mail_message
      @mail_message = mail_message
    end
    attr_reader :mail_message

    delegate *%w{
      to
      smtp_envelope_to
      from
      smtp_envelope_from
      subject
      text_part
      html_part
      body
      multipart?
      content_type
      message_id
      header
      date
      to_s
    }, to: :mail_message

    def text_content
      return text_part.try(:body).to_s if multipart?
      return body.to_s if content_type.include? 'text/plain;'
    end

    def html_content
      return html_part.try(:body).try(:to_s) if multipart?
      return body.to_s if content_type.include? 'text/html;'
    end

    def content
      "#{text_content}\n\n\n\n#{html_content}".gsub(/\s+/, ' ')
    end

    def urls
      urls = []
      URI.extract(content).each do |url|
        begin
          url = URI.parse(url)
          next if url.host == "www.w3.org"
          urls << url if URI::HTTP === url
        rescue URI::InvalidURIError
        end
      end
      urls
    end

    def html
      Nokogiri.parse(html_content.to_s)
    end

    def text
      text_content
    end

    def links text_content=nil
      links = html.css('a[href]')
      links = links.find_all{|link| link.text == text_content } if text_content.present?
      links
    end

    def link text_content
      links(text_content).first
    end

    def organization_unsubscribe_url
      urls.find{|url| url.to_s =~ %r(/unsubscribe/) }
    end

    def user_setup_url
      urls.find{|url| url.to_s =~ %r(/setup) }
    end

    def inspect
      %(#<#{self.class} from: #{from.inspect}, smtp_envelope_to: #{smtp_envelope_to.inspect}, to: #{to.inspect} subject: #{subject.inspect}>)
    end

  end

  def sent_emails
    Emails.new(ActionMailer::Base.deliveries.map{|email| Email.new(email) })
  end

end
