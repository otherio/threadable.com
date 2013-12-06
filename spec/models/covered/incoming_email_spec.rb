require 'spec_helper'

describe Covered::IncomingEmail do

  let :incoming_email_record do
    double(:incoming_email_record,
      id:                9883,
      params:            params,
      status:            'processed',
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
      'Message-ID' => "MESSAGE_ID_HEADER",
      'References' => "REFERENCES HEADER",
      'Date'       => "DATE HEADER",
    }
  end
  let(:mail_message){ double :mail_message, header: mail_message_header, from: %w{a@a.io b@b.io}, sender: 'c@c.io' }
  let(:incoming_email){ described_class.new(covered, incoming_email_record) }
  subject{ incoming_email }

  before do
    incoming_email.stub mail_message: mail_message
  end

  def params
    {
      "subject"       => "why did you do that!?",
      "body-plain"    => "go eat a goat!\n\n> you're wrong!",
      "body-html"     => "<stron>go eat a goat!<strong>\n\n<blockquote>you're wrong!</blockquote>",
      "stripped-html" => "go eat a goat!",
      "stripped-text" => "<stron>go eat a goat!<strong>",
    }
  end

  it{ should have_constant :Creator }
  it{ should have_constant :Attachments }

  it { should delegate(:id                ).to(:incoming_email_record) }
  it { should delegate(:to_param          ).to(:incoming_email_record) }
  it { should delegate(:params            ).to(:incoming_email_record) }
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


  its(:status              ){ should eq 'processed' }
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

  its(:sender_email_address){ should eq Covered::EmailAddress.new(covered, ::EmailAddress.new(address: "c@c.io")) }
  its(:from_email_addresses){ should eq [
    Covered::EmailAddress.new(covered, ::EmailAddress.new(address: "a@a.io")),
    Covered::EmailAddress.new(covered, ::EmailAddress.new(address: "b@b.io")),
  ] }

  its(:subject          ){ should eq "why did you do that!?" }
  its(:body_plain       ){ should eq "go eat a goat!\n\n> you're wrong!" }
  its(:body_html        ){ should eq "<stron>go eat a goat!<strong>\n\n<blockquote>you're wrong!</blockquote>" }
  its(:stripped_html    ){ should eq "go eat a goat!" }
  its(:stripped_plain   ){ should eq "<stron>go eat a goat!<strong>" }
  its(:message_id_header){ should eq "MESSAGE_ID_HEADER" }
  its(:references_header){ should eq "REFERENCES HEADER" }
  its(:date_header      ){ should eq "DATE HEADER" }
  its(:mail_message     ){ should eq mail_message }
  its(:inspect          ){ should eq "#<Covered::IncomingEmail id: 9883>" }

end
