require 'spec_helper'

describe "processing incoming emails" do

  before do
    EmailsController.any_instance.stub(authenticate: true)

    expect{
      expect{

        post emails_url, params
        expect(response).to be_ok
        drain_background_jobs!

      }.to change{ Message.count }.by(expected_message_count_change)
    }.to change{ Conversation.count }.by(expected_conversation_count_change)

  end

  def params
    {
      "recipient"        => recipient,
      "sender"           => sender,
      "subject"          => subject,
      "from"             => from,
      "X-Envelope-From"  => envelope_from,
      "Sender"           => sender,
      "In-Reply-To"      => in_reply_to_header,
      "References"       => references,
      "From"             => from,
      "Date"             => date.rfc2822,
      "Message-Id"       => message_id,
      "Subject"          => subject,
      "To"               => to,
      "Content-Type"     => content_type,
      "message-headers"  => [
        ["X-Envelope-From", envelope_from],
        ["Sender",          sender],
        ["In-Reply-To",     in_reply_to_header],
        ["References",      references],
        ["From",            from],
        ["Date",            date.rfc2822],
        ["Message-Id",      message_id],
        ["Subject",         subject],
        ["To",              to],
        ["Content-Type",    content_type],
      ].to_json,
      "body-plain"    => body_plain,
      "body-html"     => body_html,
      "stripped-html" => stripped_html,
      "stripped-text" => stripped_text,
    }
  end

  let(:dont_check_from_hack) { false }  #TODO: fix this
  let(:sender)            { 'yan@ucsd.covered.io' }
  let(:expected_creator)  { sender_user }
  let(:recipient)         { 'raceteam@127.0.0.1' }
  let(:to)                { 'Race Team <raceteam@127.0.0.1>' }
  let(:from)              { 'Yan Hzu <yan@ucsd.covered.io>' }
  let(:envelope_from)     { '<yan@ucsd.covered.io>' }
  let(:subject)           { 'OMG guys I love covered!' }
  let(:content_type)      { 'multipart/alternative; boundary="089e0158ba9ec5cbb704eb3fc74e"' }
  let(:date)              { 14.days.ago }
  let(:message_id)        { '<CABQbZc9oj=-_0WwB2eZKq6xLwaM2-b_X2rdjuC5qt-NFi1gDHw@mail.gmail.com>' }
  let(:in_reply_to_header){ '<5292fe2cdfe_63fafb8d97e8c626b0@covered.io>' }
  let(:references)        {
    '<CABQbZc8ngwpxZ2Mz_+ithGeRvm_bpw9GP9gxxU9WUC=YQJq6fw@mail.gmail.com> '+
    '<E828A5B5-03B0-48C5-9DA6-861115E1EE22@gmail.com> '+
    '<CALO0tS1VqrOZ6pJ9pMiTB+1Z5p9tHtAM7Z-a8=9aQPjsZM_Bqw@mail.gmail.com> '+
    '<CALO0tS1n5CX-0egtTHBRHgrm6RmncdZ4oDxw9sKEMwf=zkEeqA@mail.gmail.com> '+
    '<5292fe2cdfe_63fafb8d97e8c626b0@covered.io>'
  }
  let(:body_html)         {
    %(<p>I think we should build it out of fiberglass and duck tape.\n</p>\n)+
    %(<blockquote>)+
    %(I'm not 100% clear on the right way to go for this, but we should figure out if we're going to )+
    %(make the body out of carbon or buy a giant boat and cut it up or whatever.)+
    %(</blockquote>)
  }
  let(:body_plain)        {
    %(I think we should build it out of fiberglass and duck tape.\n\n)+
    %(> I'm not 100% clear on the right way to go for this, but we should figure out if we're going to )+
    %(> make the body out of carbon or buy a giant boat and cut it up or whatever.)
  }
  let(:stripped_html)     {
    %(<p>I think we should build it out of fiberglass and duck tape.\n</p>)
  }
  let(:stripped_text)     {
    %(I think we should build it out of fiberglass and duck tape.)
  }


  shared_context 'the email recipient is a valid project' do
    let(:sender_user)   { as('yan@ucsd.covered.io'){ current_user } }
    let(:project)       { covered.projects.find_by_slug! 'raceteam' }
    let(:recipient)     { project.email_address }
    let(:to)            { project.formatted_email_address }
  end

  shared_context 'the email recipient is not a valid project' do
    let(:recipient){ 'poopnozel@covered.io' }
    let(:to)       { 'Poop Nozel <poopnozel@covered.io>' }
  end


  shared_context "a parent message can be found via the In-Reply-To header" do
    let(:conversation)      { project.conversations.find_by_slug! 'how-are-we-going-to-build-the-body' }
    let(:parent_message)    { conversation.messages.latest }
    let(:in_reply_to_header){ "#{parent_message.message_id_header}" }
    let(:references)        {
      '<CABQbZc8ngwpxZ2Mz_+ithGeRvm_bpw9GP9gxxU9WUC=YQJq6fw@mail.gmail.com> '+
      '<E828A5B5-03B0-48C5-9DA6-861115E1EE22@gmail.com> '+
      '<CALO0tS1VqrOZ6pJ9pMiTB+1Z5p9tHtAM7Z-a8=9aQPjsZM_Bqw@mail.gmail.com> '+
      '<CALO0tS1n5CX-0egtTHBRHgrm6RmncdZ4oDxw9sKEMwf=zkEeqA@mail.gmail.com>'
    }
  end

  shared_context "a parent message can be found via the References header" do
    let(:conversation)      { project.conversations.find_by_slug! 'how-are-we-going-to-build-the-body' }
    let(:parent_message)    { conversation.messages.latest }
    let(:in_reply_to_header){ "CALO0tS1VqrOZ6pJ9pMiTB+1Z5p9tHtAM7Z-a8=9aQPjsZM_Bqw@mail.gmail.com" }
    let(:references)        {
      '<CABQbZc8ngwpxZ2Mz_+ithGeRvm_bpw9GP9gxxU9WUC=YQJq6fw@mail.gmail.com> '+
      '<E828A5B5-03B0-48C5-9DA6-861115E1EE22@gmail.com> '+
      "#{parent_message.message_id_header} "+
      '<CALO0tS1n5CX-0egtTHBRHgrm6RmncdZ4oDxw9sKEMwf=zkEeqA@mail.gmail.com>'
    }
  end

  shared_context "a parent message cannot be found" do
    let(:in_reply_to_header){ '<55555555555555555@covered.io>' }
    let(:references)        {
      '<CABQbZc8ngwpxZ2Mz_+_bpw9GP9ithGeRvmgxxU9WUC=YQJq6fw@mail.gmail.com> '+
      '<E828A5B58C5-9DA6--03B0-4861115E1EE22@gmail.com> '+
      '<CALO0tS1VqrOZ6p9tHtAM7Z-a8=9apJ9pMiTB+1Z5QPjsZM_Bqw@mail.gmail.com> '+
      '<CALO0tS1n5CXRHgrm6RmncdZ4oD-0egtTHBxw9sKEMwf=zkEeqA@mail.gmail.com> '+
      '<55555555555555555@covered.io>'
    }
  end

  shared_context 'the sender is a project member' do
    let(:sender_is_a_member){ true }
    let(:sender)       { 'yan@ucsd.covered.io' }
    let(:from)         { 'Yan Hzu <yan@ucsd.covered.io>' }
    let(:envelope_from){ '<yan@ucsd.covered.io>' }
  end

  shared_context 'the sender is not a covered member' do
    let(:sender_is_a_member){ false }
    let(:sender)       { 'steve@jobs.me' }
    let(:from)         { 'Steve Jobs <steve@jobs.me>' }
    let(:envelope_from){ '<steve@jobs.me>' }
  end

  shared_context 'the sender is a covered member who is not a project member' do
    let(:sender_is_a_member){ false }
    let(:sender_user)  { as('amywong.phd@gmail.com'){ current_user } }
    let(:sender)       { 'amywong.phd@gmail.com' }
    let(:from)         { 'Amy Wong <amywong.phd@gmail.com>' }
    let(:envelope_from){ '<amywong.phd@gmail.com>' }
  end

  shared_context 'it creates a message in a new conversation' do
    let(:message){ Message.last }
    let(:expected_conversation_count_change){ 1 }
    let(:expected_message_count_change){ 1 }
  end

  shared_examples 'it bounces the message' do
    let(:expected_conversation_count_change){ 0 }
    let(:expected_message_count_change){ 0 }
    it "bounces the message"
    #   # expect( sent_emails.count ).to eq 1
    #   # expect sent email to be a bounce message
    # end
  end

  shared_examples 'creates a new message' do
    let(:expected_message_count_change){ 1 }
    it 'creates a new message' do
      expect( message.conversation_id   ).to eq conversation.id
      expect( message.message_id_header ).to eq message_id
      expect( message.date_header       ).to eq date.rfc2822
      expect( message.references_header ).to eq references
      expect( message.subject           ).to eq subject
      expect( message.body_plain        ).to eq body_plain
      expect( message.body_html         ).to eq body_html
      expect( message.stripped_html     ).to eq stripped_html
      expect( message.stripped_plain    ).to eq stripped_text
    end
  end


  let(:project_member_email_addresses){ project.members.that_get_email.map(&:email_address) }

  shared_examples 'creates a new message with a creator' do
    include_examples 'creates a new message'
    it 'creates a new message with a creator' do
      expect(message.creator_id).to eq expected_creator.id
    end
  end

  shared_examples 'creates a new message without a creator' do
    include_examples 'creates a new message'
    it 'creates a new message without a creator' do
      expect(message.creator_id).to be_nil
    end
  end

  shared_examples 'sends emails to all project members that get email' do
    it 'sends emails to all project members that get email' do
      expected_emails_count = project_member_email_addresses.length
      expected_emails_count -= 1 if sender_is_a_member

      expect(sent_emails.count).to eq expected_emails_count
      sent_emails.each do |email|
        expect( email.message_id                ).to eq message_id[1..-2]
        expect( email.header[:References].to_s  ).to eq references
        expect( email.date.in_time_zone.rfc2822 ).to eq date.rfc2822
        expect( email.to                        ).to eq [recipient]
        expect( email.smtp_envelope_to.length   ).to eq 1
        expect( project_member_email_addresses  ).to include email.smtp_envelope_to.first
        expect( email.from                      ).to eq(email.smtp_envelope_to.include?(sender) ? [recipient] : [sender] ) unless dont_check_from_hack
        expect( email.smtp_envelope_from        ).to eq recipient
        expect( email.subject                   ).to eq "[RaceTeam] OMG guys I love covered!"
        expect( email.html_content              ).to include body_html
        expect( email.text_content              ).to include body_plain
      end
    end
  end

  shared_context 'it creates a message in an existing conversation' do
    let(:message){ Message.last }
    let(:expected_conversation_count_change){ 0 }
    let(:expected_message_count_change){ 1 }
  end

  shared_examples 'creates a new conversation' do
    it 'creates a new conversation' do
      expect( conversation.project_id     ).to eq project.id
      expect( conversation.creator_id     ).to eq expected_creator.id
      expect( conversation.subject        ).to eq subject
      expect( conversation.messages_count ).to eq 1
    end
  end

  shared_examples 'it creates a message in a new conversation' do
    let(:message){ Message.last }
    let(:conversation){ Conversation.last }
    let(:expected_conversation_count_change){ 1 }
    let(:expected_message_count_change){ 1 }
    include_examples 'creates a new message with a creator'
    include_examples 'creates a new conversation'
    include_examples 'sends emails to all project members that get email'
  end



  # The actual tests :P - Jared

  context "when the project is not found" do
    include_context 'the email recipient is not a valid project'
    include_examples 'it bounces the message'
  end

  context "when the project is found" do
    include_context 'the email recipient is a valid project'

    context "and a parent message is found via the In-Reply-To header" do
      include_context "a parent message can be found via the In-Reply-To header"
      include_context 'it creates a message in an existing conversation'
      context "and the sender is a project member" do
        include_context 'the sender is a project member'
        include_examples 'creates a new message with a creator'
        include_examples 'sends emails to all project members that get email'
      end

      context "and the sender is not a covered member" do
        include_context 'the sender is not a covered member'
        include_examples 'creates a new message without a creator'
        include_examples 'sends emails to all project members that get email'
        context 'but the from address is a project member' do
          let(:sender_is_a_member) { true }
          let(:expected_creator)   { as('yan@ucsd.covered.io'){ current_user } }
          let(:from){ 'Yan Hzu <yan@ucsd.covered.io>' }
          include_examples 'creates a new message with a creator'
        end
      end

      context "and the sender is a covered member who is not a project member" do
        include_context 'the sender is a covered member who is not a project member'
        include_examples 'creates a new message with a creator'
        include_examples 'sends emails to all project members that get email'
        context 'but the from address is a project member' do
          let(:sender_is_a_member) { true }
          let(:expected_creator)   { as('yan@ucsd.covered.io'){ current_user } }
          let(:from){ 'Yan Hzu <yan@ucsd.covered.io>' }
          include_examples 'creates a new message with a creator'
        end
      end
    end

    context "and the parent message is found via the References header" do
      include_context "a parent message can be found via the References header"
      include_context 'it creates a message in an existing conversation'

      context "and the sender is a project member" do
        include_context 'the sender is a project member'
        include_examples 'creates a new message with a creator'
        include_examples 'sends emails to all project members that get email'
      end

      context "and the sender is not a covered member" do
        include_context 'the sender is not a covered member'
        include_examples 'creates a new message without a creator'
        include_examples 'sends emails to all project members that get email'
      end

      context "and the sender is a covered member who is not a project member" do
        include_context 'the sender is a covered member who is not a project member'
        include_examples 'creates a new message with a creator'
        include_examples 'sends emails to all project members that get email'
      end
    end

    context "and the parent message is not found" do
      include_context "a parent message cannot be found"

      context "and the sender is a project member" do
        include_context 'the sender is a project member'
        include_examples 'it creates a message in a new conversation'
      end

      context "and the sender is not a covered member" do
        include_context 'the sender is not a covered member'

        context "and the from address is not a project member" do
          include_examples 'it bounces the message'
        end

        context "but the from address is a project member" do
          let(:sender_is_a_member) { true }
          let(:expected_creator)   { as('yan@ucsd.covered.io'){ current_user } }
          let(:from){ 'Yan Hzu <yan@ucsd.covered.io>' }
          let(:dont_check_from_hack) { true }  #TODO: fix this
          include_examples 'it creates a message in a new conversation'
        end
      end

      context "and the sender is a covered member who is not a project member" do
        include_context 'the sender is a covered member who is not a project member'

        context "and the from address is not a project member" do
          include_examples 'it bounces the message'
        end

        context "but the from address is a project member" do
          let(:sender_is_a_member) { true }
          let(:expected_creator)   { as('yan@ucsd.covered.io'){ current_user } }
          let(:from){ 'Yan Hzu <yan@ucsd.covered.io>' }
          let(:dont_check_from_hack) { true }  #TODO: fix this
          include_examples 'it creates a message in a new conversation'
        end
      end

      # include_context "when this message has CC recipients"
      # include_context "when the message has multiple recipients in the to header"
    end
  end

end
