require 'spec_helper'

describe Covered::Operations::CreateMessageFromIncomingEmail do

  before do
    FilepickerUploader::Uploader.should_not_receive(:perform_request)
  end

  let!(:original_conversation_count){ Covered::Conversation.count }
  let!(:original_message_count){ Covered::Message.count }
  let!(:original_attachment_count){ Covered::Attachment.count }
  let(:project){ Covered::Project.where(name: "UCSD Electric Racing").first! }
  let(:sender){ Covered::User.with_email('alice@ucsd.covered.io').first! }
  let(:in_reply_to_header){ nil }
  let(:recipient_param){ 'UCSD Electric Racing <raceteam@covered.io>' }
  let(:from_param){ 'Alice Neilson <alice@ucsd.covered.io>' }

  let(:message_headers) do
    {'Message-Id' => '<3j4hjk35hk4h32423k@hackers.io>', 'In-Reply-To' => in_reply_to_header}
  end

  let(:params) do
    create_incoming_email_params(
      'message-headers' => message_headers,
      'recipient' => recipient_param,
      'from' => from_param,
    )
  end

  let(:incoming_email) do
    Covered::IncomingEmail.create! params: params
  end

  # Helpers

  def call!
    @message = Covered::Operations::CreateMessageFromIncomingEmail.call(covered: covered, :incoming_email_id => incoming_email.id)
  end

  def strip_body(body)
    covered.strip_user_specific_content_from_email_message_body(:body => body)
  end

  def attachments
    attachments_for_email_params(params)
  end


  # Setups

  def self.in_reply_to_a_known_conversation!
    let(:conversation){ project.conversations.where(subject: 'layup body carbon').first! }
    let(:parent_message){ conversation.messages.first! }
    let(:in_reply_to_header){ parent_message.message_id_header }
  end

  def self.in_reply_to_an_unknown_conversation!
    let(:conversation){ nil }
    let(:parent_message){ nil }
    let(:in_reply_to_header){ '<somefakeunknowbsmessageidheader@covered.io>' }
  end


  # Shoulds

  def self.it_should_upload_attachments!
    before do
      attachments.each do |attachment|
        mock_filepicker_upload_for(attachment)
      end
    end
  end

  def self.it_should_create_a_message!
    it_should_upload_attachments!

    it "should create a message" do
      call!
      expect(Covered::Message.count   ).to eq original_message_count + 1
      expect(Covered::Attachment.count).to eq original_attachment_count + attachments.size
      validate_message!
    end
  end

  def self.it_should_not_create_a_message!
    it "should not create a message" do
      # expect{ call! }.to raise_error "unabled to find project for incoming email #{incoming_email.id}"
      call!
      expect(Covered::Message.count   ).to eq original_message_count
      expect(Covered::Attachment.count).to eq original_attachment_count
    end
  end

  def self.it_should_create_a_conversation!
    let(:conversation){ nil }
    let(:expected_conversation_creator){ sender }
    it "should create a conversation" do
      call!
      expect(Covered::Conversation.count).to eq original_conversation_count + 1
      validate_conversation!
    end
  end

  def self.it_should_not_create_a_conversation!
    it "should not create a conversation" do
      call!
      expect(Covered::Conversation.count).to eq original_conversation_count
    end
  end



  def self.it_should_create_a_message_and_a_conversation!
    context do
      it_should_create_a_message!
      it_should_create_a_conversation!
    end
  end

  def self.it_should_create_a_message_but_not_a_conversation!
    context do
      it_should_create_a_message!
      it_should_not_create_a_conversation!
    end
  end




  # Validations

  def validate_message!
    assert_background_job_enqueued(covered, :send_conversation_message, message_id: @message.id)

    expect(@message.message_id_header).to     eq message_headers['Message-Id']
    expect(@message.subject).to               eq expected_subject
    expect(@message.parent_message).to        eq expected_parent_message
    expect(@message.user).to                  eq expected_sender
    expect(@message.from).to                  eq expected_sender_email
    expect(@message.body_plain).to            eq strip_body(params['body-plain'])
    expect(@message.body_html).to             eq strip_body(params['body-html'])
    expect(@message.stripped_plain).to        eq strip_body(params['stripped-text'])
    expect(@message.stripped_html).to         eq strip_body(params['stripped-html'])
    expect(@message.conversation).to          be_present
    expect(@message.conversation.project).to  eq project

    attachment_data = @message.attachments.map{|a| [a.filename, a.content] }.to_set
    expected_attachment_data = attachments.map{|a| [a.original_filename, a.read]}.to_set
    expect(attachment_data).to eq(expected_attachment_data)
  end

  def validate_conversation!
    expect(@message.conversation.task?).to eq conversation_should_be_a_task
    expect(@message.conversation.subject).to eq expected_subject
    expect(@message.conversation.creator).to eq expected_conversation_creator
    expect(@message.conversation.project).to eq project
  end


  # Tests

  let(:expected_subject){ params['subject'] }
  let(:expected_parent_message){ parent_message }
  let(:expected_sender){ sender }
  let(:expected_sender_email){ sender.email }
  let(:conversation_should_be_a_task){ false }

  context "when the message is sent to a known project" do
    context "and the message is not a reply" do
      let(:parent_message){ nil }

      it_should_create_a_message_and_a_conversation!
      context "and the subject starts with 'task: '" do
        let(:conversation_should_be_a_task){ true }
        let(:expected_subject){ 'create a jig' }
        before{ params["subject"] = 'Task: create a jig' }
        it_should_create_a_message_and_a_conversation!
      end
      context "and the subject starts with '✔ '" do
        let(:conversation_should_be_a_task){ true }
        let(:expected_subject){ 'create a jig' }
        before{ params["subject"] = '✔ create a jig' }
        it_should_create_a_message_and_a_conversation!
      end
    end

    context "and the message is a reply" do
      context "to an unknown conversation" do
        in_reply_to_an_unknown_conversation!
        it_should_create_a_message_and_a_conversation!
      end

      context "to an known conversation" do
        in_reply_to_a_known_conversation!
        it_should_create_a_message_but_not_a_conversation!
      end

      context "to a message of another project" do
        let(:other_project){ Covered::Project.where(name: "Mars Exploration Rover").first! }
        let(:parent_message){ other_project.conversations.first!.messages.first! }
        let(:expected_parent_message){ nil }
        let(:in_reply_to_header){ parent_message.message_id_header }
        it_should_create_a_message_and_a_conversation!
      end
    end
  end

  context "when the message is sent to a unknown project" do
    let(:recipient_param){ '"Unknown Covered::Project" <some-bullshit-email-address@covered.io>' }
    it "should raise an error" do
      expect{ call! }.to raise_error "unabled to find project for incoming email #{incoming_email.id}"
    end
  end

  context "when the message is sent by an unknown user" do
    let(:from_param){ 'Random Person <whoknows@example.com>' }
    context "in reply to a known conversation" do
      let(:expected_sender){ nil }
      let(:expected_sender_email){ 'whoknows@example.com' }
      in_reply_to_a_known_conversation!
      it_should_create_a_message_but_not_a_conversation!
    end
    context "in reply to a unknown conversation" do
      in_reply_to_an_unknown_conversation!
      it "should raise an error" do
        expect{ call! }.to raise_error "unable to find a user or a pre existing conversation for incoming email #{incoming_email.id}"
      end
    end
  end

end
