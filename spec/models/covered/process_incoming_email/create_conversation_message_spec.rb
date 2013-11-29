require 'spec_helper'

describe Covered::ProcessIncomingEmail::CreateConversationMessage do

  let(:covered){ double(:covered, users: double(:users)) }
  let(:current_user){ double(:current_user, projects: double(:projects)) }

  let :incoming_email do
    double(:incoming_email,
      message_id_header:       message_id_header,
      references_header:       references_header,
      date_header:             date_header,
      recipient_email_address: recipient_email_address,
      sender_email_address:    sender_email_address,
      from_email_address:      from_email_address,
      from_email_addresses:    from_email_addresses,
      subject:                 subject,
      body_plain:              body_plain,
      body_html:               body_html,
      stripped_plain:          stripped_plain,
      stripped_html:           stripped_html,
      header:                  header,
      attachments:             attachments,
    )
  end

  let(:message_id_header)       { '<dsjsjakdjksahk@asdsadsad.com>' }
  let(:references_header)       { '<ytutyu@yuiuy.com> <opopop@opopop.com> <fgfgfg@fgfgf.com>' }
  let(:date_header)             { 18.days.ago.rfc2822 }
  let(:recipient_email_address) { 'poopatron@covered.io' }
  let(:sender_email_address)    { 'smelly@poopatron.com' }
  let(:from_email_address)      { 'fromguy@poopatron.com' }
  let(:from_email_addresses)    { [sender_email_address, from_email_address] }
  let(:subject)                 { 'we need coffee' }
  let(:body_html)               { "<p>hey people,</p>\n<p>Who drank all the coffee!?</p><blockquote>the previous message</blockquote>"}
  let(:body_plain)              { "hey people,\n\nWho drank all the coffee!?\n\n> the previous message" }
  let(:stripped_html)           { "<p>hey people,</p>\n<p>Who drank all the coffee!?</p>"}
  let(:stripped_plain)          { "hey people,\n\nWho drank all the coffee!?" }
  let(:header)                  {}

  let :attachments do
    []
  end

  def header
    {
      'Message-ID' => 'FAKE MESSAGE ID',
    }
  end

  let(:creator       ){ double(:creator, id: 89, projects: double(:projects)) }
  let(:project       ){ double(:project, messages: double(:project_messages)) }

  let(:conversation  ){ double(:conversation, messages: double(:conversation_messages), task?: task) }
  let(:task          ){ false }
  let(:new_message   ){ double(:new_message) }


  let(:expected_message_id_header) { '<dsjsjakdjksahk@asdsadsad.com>' }
  let(:expected_references_header) { '<ytutyu@yuiuy.com> <opopop@opopop.com> <fgfgfg@fgfgf.com>' }
  let(:expected_date_header)       { 18.days.ago.rfc2822 }
  let(:expected_subject)           { "we need coffee" }
  let(:expected_from)              { 'fromguy@poopatron.com' }
  let(:expected_parent_message)    { parent_message }
  let(:expected_creator_id)        { 89 }
  let(:expected_body_html)         { "<p>hey people,</p>\n<p>Who drank all the coffee!?</p><blockquote>the previous message</blockquote>"}
  let(:expected_body_plain)        { "hey people,\n\nWho drank all the coffee!?\n\n> the previous message" }
  let(:expected_stripped_html)     { "<p>hey people,</p>\n<p>Who drank all the coffee!?</p>"}
  let(:expected_stripped_plain)    { "hey people,\n\nWho drank all the coffee!?" }
  let(:expected_attachments)       { [] }

  before do
    expect(covered.users   ).to receive(:find_by_email_address       ).with(sender_email_address   ).and_return(creator)
    expect(covered         ).to receive(:current_user_id=            ).with(89)
    expect(covered         ).to receive(:current_user                ).and_return(current_user)
    expect(current_user.projects).to receive(:find_by_email_address  ).with(recipient_email_address).and_return(project)
    expect(project.messages).to receive(:find_by_child_message_header).with(header                 ).and_return(parent_message)

    expect(conversation.messages).to receive(:create!).with(

      message_id_header: expected_message_id_header,
      references_header: expected_references_header,
      date_header:       expected_date_header,
      subject:           expected_subject,
      parent_message:    expected_parent_message,
      from:              expected_from,
      body_plain:        expected_body_plain,
      body_html:         expected_body_html,
      stripped_plain:    expected_stripped_plain,
      stripped_html:     expected_stripped_html,
      attachments:       expected_attachments,
    ).and_return(new_message)
  end

  def call!
    described_class.call(covered, incoming_email)
  end

  def self.it_should_create_a_new_conversation_message!
    it "should create a new conversation message" do
      expect(call!).to eq new_message
    end
  end

  context "when there is a parent message" do
    let(:parent_message){ double(:parent_message, id: 883, conversation: conversation) }
    it_should_create_a_new_conversation_message!

    context "when the conversation is a task" do
      let(:task){ true }
      let(:subject){ 'task: buy some coffee' }
      let(:expected_subject){ 'buy some coffee' }
      it_should_create_a_new_conversation_message!
    end
  end


  context "when there isn't a parent message" do
    let(:parent_message){ nil }
    let(:expected_parent_message_id){ nil }
    let(:project_conversations){ double(:project_conversations) }

    before do
      if task
        expect(project).to receive(:tasks).and_return(project_conversations)
      else
        expect(project).to receive(:conversations).and_return(project_conversations)
      end
      expect(project_conversations).to receive(:create).with(subject: expected_subject).and_return(conversation)
    end

    it_should_create_a_new_conversation_message!

    context "when the subject starts with 'task: '" do
      let(:task){ true }
      let(:subject){ 'task: buy some coffee' }
      let(:expected_subject){ 'buy some coffee' }
      it_should_create_a_new_conversation_message!
    end

    context "when the subject starts with '✔ '" do
      let(:task){ true }
      let(:subject){ '✔ buy some coffee' }
      let(:expected_subject){ 'buy some coffee' }
      it_should_create_a_new_conversation_message!
    end
  end

  describe "#creator" do
    let(:parent_message){ nil }
    let(:expected_parent_message_id){ nil }
    let(:project_conversations){ double(:project_conversations) }

    before do
      expect(project).to receive(:conversations).and_return(project_conversations)
      expect(project_conversations).to receive(:create).with(subject: expected_subject).and_return(conversation)
    end

    context "when the envelope sender is a user" do
      before do
        covered.users.stub(:find_by_email_address!).with(sender_email_address).and_return(creator)
      end
      it_should_create_a_new_conversation_message!
    end

    context "when the envelope sender is not a user, but the from address is" do
      before do
        covered.users.stub(:find_by_email_address).with(sender_email_address).and_return(nil)
        covered.users.stub(:find_by_email_address!).with(from_email_address).and_return(creator)
      end
      it_should_create_a_new_conversation_message!
    end

    context "when neither envelope nor from are users" do
      before do
        # expect(covered.users).to receive(:find_by_email_address!).with(sender_email_address).and_return(nil)
        # expect(covered.users).to receive(:find_by_email_address!).with(from_email_address).and_raise()
      end

      it 'bounces the message or sticks it into some queue or something useful like that'

    end
  end

end
