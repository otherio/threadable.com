require 'spec_helper'

describe IncomingEmail do

  def message_headers
    [
    ]
  end

  def params
    {
      'message-headers' => message_headers.to_json
    }
  end

  let(:incoming_email){ IncomingEmail.new(params: params) }
  subject{ incoming_email }


  describe "recipient_email_address" do
    it 'should curry params["recipient"]' do
      expect(subject.params).to receive(:[]).with('recipient')
      subject.recipient_email_address
    end
  end

  describe "sender_email_address" do
    it 'should curry params["sender"]' do
      expect(subject.params).to receive(:[]).with('sender')
      subject.sender_email_address
    end
  end

  describe "subject" do
    it 'should curry params["subject"]' do
      expect(subject.params).to receive(:[]).with('subject')
      subject.subject
    end
  end

  describe "body_plain" do
    it 'should curry params["body-plain"]' do
      expect(subject.params).to receive(:[]).with('body-plain')
      subject.body_plain
    end
  end

  describe "body_html" do
    it 'should curry params["body-html"]' do
      expect(subject.params).to receive(:[]).with('body-html')
      subject.body_html
    end
  end

  describe "stripped_html" do
    it 'should curry params["stripped-html"]' do
      expect(subject.params).to receive(:[]).with('stripped-html')
      subject.stripped_html
    end
  end

  describe "stripped_plain" do
    it 'should curry params["stripped-text"]' do
      expect(subject.params).to receive(:[]).with('stripped-text')
      subject.stripped_plain
    end
  end

  describe "header" do
    it "should curry to mail_message" do
      expect(subject.mail_message).to receive(:header)
      subject.header
    end
  end

  describe "attachments" do
    it "should curry to mail_message" do
      expect(subject.mail_message).to receive(:attachments)
      subject.attachments
    end
  end

  describe "mail_message" do
    subject{ incoming_email.mail_message }
    it { should be_a Mail::Message }
  end

end
