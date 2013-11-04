require 'spec_helper'

describe Covered::IncomingEmail do

  let :project do
    find_project('raceteam')
  end

  let :conversation do
    project.conversations.first
  end

  let :parent_message do
    conversation.messages.first
  end

  let :message_headers do
    message_headers = {
      'Message-Id' => '<3j4hjk35hk4h32423k@hackers.io>'
    }
    message_headers['In-Reply-To'] = parent_message.message_id_header if parent_message
    message_headers
  end

  let :params do
    create_incoming_email_params(
      'from'             => 'Alice Neilson <alice@ucsd.covered.io>',
      'recipient'        => 'UCSD Electric Racing <raceteam@covered.io>',
      'subject'          => 'this is the subject',
      'message-headers'  => message_headers,
      'body-plain'       => "hello there\n> hi you",
      'stripped-text'    => "hello there",
      'body-html'        => "<p>hello <b>there</b></p>\n> <p><b>hi</b> you</p>",
      'stripped-html'    => "<p>hello <b>there</b></p>",
    )
  end

  let(:email){ described_class.new(params: params) }

  subject{ email }

  describe "#mail_message" do
    it "should return a Mail::Message" do
      expect(email.mail_message).to be_a Mail::Message
      expect(email.to).to eq ["raceteam@covered.io"]
      expect(email.from).to eq ["alice@ucsd.covered.io"]
      expect(email.subject).to eq "this is the subject"

      attachment_details = email.attachments.map do |a|
        [a.filename, a.mime_type, a.content_transfer_encoding]
      end

      expect(attachment_details.to_set).to eq Set[
        ["some.gif", "image/gif", "binary"],
        ["some.jpg", "image/jpeg", "binary"],
        ["some.txt", "text/plain", "7bit"]
      ]

      expect(email.header["Message-ID"].to_s).to eq "<3j4hjk35hk4h32423k@hackers.io>"
    end
  end

  %w{
    attachments
    to
    from
    header
    subject
  }.each do |method|
    describe "#method" do
      it "should delegate to mail_message" do
        expect(email.mail_message).to receive method
        email.public_send(method)
      end
    end
  end

  describe "#text_part" do
    subject{ email.text_part }
    it { should == "hello there\n> hi you" }
  end

  describe "#html_part" do
    subject{ email.html_part }
    it { should == "<p>hello <b>there</b></p>\n> <p><b>hi</b> you</p>" }
  end

  describe "#text_part_stripped" do
    subject{ email.text_part_stripped }
    it { should == "hello there" }
  end

  describe "#html_part_stripped" do
    subject{ email.html_part_stripped }
    it { should == "<p>hello <b>there</b></p>" }
  end

  describe "#project_email_address_username" do
    subject{ email.project_email_address_username }
    # it { should == "raceteam" }

    before do
      email.stub(:to).and_return(to)
    end

    context "when the to array contains email addresses that looks like a project email" do
      context "for production" do
        let(:to){ [Faker::Internet.email, 'make-a-duck@beta.covered.io', Faker::Internet.email] }
        it { should == 'make-a-duck' }
      end
      context "for staging" do
        let(:to){ [Faker::Internet.email, 'make-a-duck@www-staging.covered.io', Faker::Internet.email] }
        it { should == 'make-a-duck' }
      end
    end

    context "when the to array contains email addresses that dont look like a project email" do
      let(:to){ [Faker::Internet.email, Faker::Internet.email, Faker::Internet.email] }
      it { should be_nil }
    end

  end

  describe "#project" do
    subject{ email.project }
    it { should == project }
  end

  describe "#parent_message" do
    subject{ email.parent_message }
    it { should == parent_message }
    context "when there is no parent message" do
      let(:parent_message){ nil }
      it { should be_nil}
    end
  end

  describe "#conversation" do
    subject{ email.conversation }
    it { should == conversation }
    context "when there is no parent message" do
      let(:parent_message){ nil }
      it { should be_nil}
    end
  end

end
