require 'spec_helper'

describe Covered::IncomingEmail do

  let :incoming_email_record do
    double(:incoming_email_record,
      id:                9883,
      params:            params,
      processed?:        true,
      failed?:           true,
      creator_id:        1302,
      project_id:        194,
      project:           double(:project, id: 194),
      conversation_id:   887,
      conversation:      double(:conversation, id: 887, task?: true),
      message_id:        9413,
      message:           double(:message, id: 9413),
      parent_message_id: 14,
      parent_message:    double(:parent_message, id: 14),
    )
  end
  let :mail_message_header do
    {
      'References' => "REFERENCES HEADER",
      'Date'       => "DATE HEADER",
    }
  end
  let(:mail_message){ double :mail_message, header: mail_message_header, from: %w{a@a.io b@b.io}}
  let(:incoming_email){ described_class.new(covered, incoming_email_record) }
  subject{ incoming_email }

  before do
    incoming_email.stub mail_message: mail_message
  end

  def params
    {
      "sender"        => 'c@c.io',
      "subject"       => "why did you do that!?",
      "body-plain"    => "go eat a goat!\n\n> you're wrong!",
      "body-html"     => "<stron>go eat a goat!<strong>\n\n<blockquote>you're wrong!</blockquote>",
      "stripped-html" => "go eat a goat!",
      "stripped-text" => "<stron>go eat a goat!<strong>",
      'Message-Id'    => "MESSAGE_ID_HEADER",
    }
  end

  it{ should have_constant :Creator }
  it{ should have_constant :Attachments }

  it { should delegate(:id                ).to(:incoming_email_record) }
  it { should delegate(:to_param          ).to(:incoming_email_record) }
  it { should delegate(:params            ).to(:incoming_email_record) }
  it { should delegate(:processed?        ).to(:incoming_email_record) }
  it { should delegate(:failed?           ).to(:incoming_email_record) }
  it { should delegate(:creator_id        ).to(:incoming_email_record) }
  it { should delegate(:creator_id=       ).to(:incoming_email_record) }
  it { should delegate(:project_id        ).to(:incoming_email_record) }
  it { should delegate(:project_id=       ).to(:incoming_email_record) }
  it { should delegate(:conversation_id   ).to(:incoming_email_record) }
  it { should delegate(:conversation_id=  ).to(:incoming_email_record) }
  it { should delegate(:message_id        ).to(:incoming_email_record) }
  it { should delegate(:message_id=       ).to(:incoming_email_record) }
  it { should delegate(:parent_message_id ).to(:incoming_email_record) }
  it { should delegate(:parent_message_id=).to(:incoming_email_record) }
  it { should delegate(:message_id        ).to(:incoming_email_record) }
  it { should delegate(:message_id=       ).to(:incoming_email_record) }
  it { should delegate(:created_at        ).to(:incoming_email_record) }
  it { should delegate(:errors            ).to(:incoming_email_record) }
  it { should delegate(:persisted?        ).to(:incoming_email_record) }

  it{ should be_processed }
  its(:creator             ){ should be_a Covered::IncomingEmail::Creator }
  its(:attachments         ){ should be_a Covered::IncomingEmail::Attachments }
  describe 'project' do
    it 'returns a Covered::Project and memoizes it' do
      project = double :project
      expect(Covered::Project).to receive(:new).once.with(covered, incoming_email_record.project).and_return(project)
      expect(incoming_email.project).to eq project
      expect(incoming_email.project).to eq project
    end
  end
  describe 'conversation' do
    it 'returns a Covered::Conversation and memoizes it' do
      conversation = double :conversation
      expect(Covered::Conversation).to receive(:new).once.with(covered, incoming_email_record.conversation).and_return(conversation)
      expect(incoming_email.conversation).to eq conversation
      expect(incoming_email.conversation).to eq conversation
    end
  end
  describe 'message' do
    it 'returns a Covered::Message and memoizes it' do
      message = double :message
      expect(Covered::Message).to receive(:new).once.with(covered, incoming_email_record.message).and_return(message)
      expect(incoming_email.message).to eq message
      expect(incoming_email.message).to eq message
    end
  end
  describe 'parent_message' do
    it 'returns a Covered::Message and memoizes it' do
      parent_message = double :parent_message
      expect(Covered::Message).to receive(:new).once.with(covered, incoming_email_record.parent_message).and_return(parent_message)
      expect(incoming_email.parent_message).to eq parent_message
      expect(incoming_email.parent_message).to eq parent_message
    end
  end

  its(:sender_email_address){ should eq "c@c.io" }
  its(:from_email_addresses){ should eq %w{a@a.io b@b.io c@c.io} }
  its(:subject             ){ should eq "why did you do that!?" }
  its(:body_plain          ){ should eq "go eat a goat!\n\n> you're wrong!" }
  its(:body_html           ){ should eq "<stron>go eat a goat!<strong>\n\n<blockquote>you're wrong!</blockquote>" }
  its(:stripped_html       ){ should eq "go eat a goat!" }
  its(:stripped_plain      ){ should eq "<stron>go eat a goat!<strong>" }
  its(:message_id_header   ){ should eq "MESSAGE_ID_HEADER" }
  its(:references_header   ){ should eq "REFERENCES HEADER" }
  its(:date_header         ){ should eq "DATE HEADER" }
  its(:mail_message        ){ should eq mail_message }
  its(:inspect             ){ should eq %(#<Covered::IncomingEmail id: 9883, processed: true, failed: true, from: nil, creator_id: 1302, project_id: 194, conversation_id: 887, message_id: 9413>) }


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

  describe "from_email_address" do
    it 'should curry params["from"]' do
      expect(subject.params).to receive(:[]).with('from')
      subject.from_email_address
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
      expect(described_class::Attachments).to receive(:new).with(subject)
      subject.attachments
    end
  end

  describe "mail_message" do
    subject{ incoming_email.mail_message }
    it { should be mail_message }
  end


end
