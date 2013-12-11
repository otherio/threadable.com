require 'spec_helper'

describe "processing incoming emails" do

  before do
    EmailsController.any_instance.stub(authenticate: true)

    expect{
      expect{

        expect{
          post emails_url, params
          expect(response).to be_ok
        }.to change{ IncomingEmail.count }.by(1)

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
      "Cc"               => cc,
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
        ["Cc",              cc],
        ["Content-Type",    content_type],
      ].to_json,
      "body-plain"    => body_plain,
      "body-html"     => body_html,
      "stripped-html" => stripped_html,
      "stripped-text" => stripped_text,
    }
  end

  let(:sender)            { 'yan@ucsd.covered.io' }
  let(:expected_creator)  { sender_user }
  let(:recipient)         { 'raceteam@127.0.0.1' }
  let(:to)                { 'Race Team <raceteam@127.0.0.1>, Someone Else <someone@example.com>' }
  let(:cc)                { 'Another Guy <another@guy.io>, Your Mom <mom@yourmom.com>' }
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
  let(:expected_sent_email_to          ){ ['raceteam@127.0.0.1', 'someone@example.com'] }
  let(:expected_sent_email_cc          ){ 'Another Guy <another@guy.io>, Your Mom <mom@yourmom.com>' }
  let(:expected_from                   ){ sender }
  let(:expected_conversation_subject   ){ "OMG guys I love covered!" }
  let(:expected_message_subject        ){ subject }
  let(:expected_sent_email_subject     ){ "[RaceTeam] OMG guys I love covered!" }
  let(:expect_conversation_to_be_a_task){ false }
  let(:expected_smtp_envelope_from){ recipient }


  shared_context 'the email recipient is a valid project' do
    let(:sender_user)              { as('yan@ucsd.covered.io'){ current_user } }
    let(:project)                  { covered.projects.find_by_slug! 'raceteam' }
    let(:recipient)                { project.email_address }
    let(:to)                       { project.formatted_email_address }
    let(:expected_sent_email_to)   { [project.email_address] }

  end

  shared_context 'the email recipient is not a valid project' do
    let(:recipient)  { 'poopnozel@covered.io' }
    let(:to)         { 'Poop Nozel <poopnozel@covered.io>' }
    let(:expected_sent_email_to){ ['poopnozel@covered.io'] }
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
    let(:expected_sent_email_cc)  { "Another Guy <another@guy.io>, Your Mom <mom@yourmom.com>, #{from}" }
  end

  shared_context 'the sender is a covered member who is not a project member' do
    let(:sender_is_a_member){ false }
    let(:sender_user)  { as('amywong.phd@gmail.com'){ current_user } }
    let(:sender)       { 'amywong.phd@gmail.com' }
    let(:from)         { 'Amy Wong <amywong.phd@gmail.com>' }
    let(:envelope_from){ '<amywong.phd@gmail.com>' }
    let(:expected_sent_email_cc)  { "Another Guy <another@guy.io>, Your Mom <mom@yourmom.com>, #{from}" }
  end

  shared_context 'the from address is a project member' do
    let(:sender_is_a_member) { true }
    let(:expected_creator)   { as('yan@ucsd.covered.io'){ current_user } }
    let(:from){ 'Yan Hzu <yan@ucsd.covered.io>' }
    let(:expected_from) { 'yan@ucsd.covered.io' }
    let(:expected_sent_email_cc){ 'Another Guy <another@guy.io>, Your Mom <mom@yourmom.com>' }
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
      expect( message.to_header         ).to eq to
      expect( message.cc_header         ).to eq cc
      expect( message.date_header       ).to eq date.rfc2822
      expect( message.references_header ).to eq references
      expect( message.subject           ).to eq expected_message_subject
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
        expect( email.to                        ).to eq expected_sent_email_to
        expect( email.header[:Cc].to_s          ).to eq expected_sent_email_cc
        expect( email.smtp_envelope_to.length   ).to eq 1
        expect( project_member_email_addresses  ).to include email.smtp_envelope_to.first
        expect( email.from                      ).to eq(email.smtp_envelope_to.include?(sender) ? [recipient] : [expected_from] )
        expect( email.smtp_envelope_from        ).to eq expected_smtp_envelope_from
        expect( email.subject                   ).to eq expected_sent_email_subject
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
      if expect_conversation_to_be_a_task
        expect( conversation ).to be_task
      else
        expect( conversation ).to_not be_task
      end
      expect( conversation.project_id     ).to eq project.id
      expect( conversation.creator_id     ).to eq expected_creator.id
      expect( conversation.subject        ).to eq expected_conversation_subject
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

        context "and only members are specified in the to header, but the project is in cc" do
          let(:to) { 'Alice Neilson <alice@ucsd.covered.io>' }
          let(:cc) { 'Race Team <raceteam@127.0.0.1>' }
          let(:expected_sent_email_to) { ['raceteam@127.0.0.1'] }
          let(:expected_sent_email_cc) { '' }

          include_examples 'creates a new message with a creator'
          include_examples 'sends emails to all project members that get email'
        end
      end

      context "and the sender is not a covered member" do
        include_context 'the sender is not a covered member'
        include_examples 'creates a new message without a creator'
        include_examples 'sends emails to all project members that get email'

        context 'but the from address is a project member' do
          include_context 'the from address is a project member'
          include_examples 'creates a new message with a creator'
        end
      end

      context "and the sender is a covered member who is not a project member" do
        include_context 'the sender is a covered member who is not a project member'
        include_examples 'creates a new message with a creator'
        include_examples 'sends emails to all project members that get email'

        context 'but the from address is a project member' do
          include_context 'the from address is a project member'
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

        context "and the from address is not a project member" do
          let(:from){ 'Larry TheTvGuy <larry@tvsrus.net>' }
          let(:expected_from) { 'larry@tvsrus.net' }
          include_examples 'it creates a message in a new conversation'
        end

        context "and the subject is in japanese" do
          let(:subject) { "おはいよございます！げんきですか？" }
          let(:expected_conversation_subject   ){ "おはいよございます！げんきですか？" }
          let(:expected_message_subject        ){ subject }
          let(:expected_sent_email_subject     ){ "[RaceTeam] おはいよございます！げんきですか？" }

          include_examples 'it creates a message in a new conversation'
        end

        context "and the subject has emoji" do
          let(:subject) { "I love the snow! ☃❅❆" }
          let(:expected_conversation_subject   ){ "I love the snow! ☃❅❆" }
          let(:expected_message_subject        ){ subject }
          let(:expected_sent_email_subject     ){ "[RaceTeam] I love the snow! ☃❅❆" }

          include_examples 'it creates a message in a new conversation'
        end

        context "and the message was sent to the +task address" do
          let(:expect_conversation_to_be_a_task){ true }
          let(:recipient){ 'raceteam+task@127.0.0.1' }
          let(:to){ 'Race Team Task <raceteam+task@127.0.0.1>, Someone Else <someone@example.com>' }
          let(:expected_sent_email_to){ ['raceteam+task@127.0.0.1', 'someone@example.com'] }
          let(:expected_conversation_subject){ "OMG guys I love covered!" }
          let(:expected_sent_email_subject){ "[✔][RaceTeam] OMG guys I love covered!" }
          include_examples 'it creates a message in a new conversation'

          context 'and the subject has some other [tag]' do
            let(:subject){ "[ruby-docs] rvm 1.9.2 has a security hole" }
            let(:expected_conversation_subject){ "[ruby-docs] rvm 1.9.2 has a security hole" }
            let(:expected_sent_email_subject){ "[✔][RaceTeam] [ruby-docs] rvm 1.9.2 has a security hole" }
            let(:expected_smtp_envelope_from){ 'raceteam+task@127.0.0.1' }
            include_examples 'it creates a message in a new conversation'
          end
        end

        context "and the subject contains [task]" do
          let(:expect_conversation_to_be_a_task){ true }
          let(:subject){ "[task] pickup some fried chicken" }
          let(:expected_conversation_subject){ "pickup some fried chicken" }
          let(:expected_sent_email_subject){ "[✔][RaceTeam] pickup some fried chicken" }
          let(:expected_smtp_envelope_from){ 'raceteam+task@127.0.0.1' }
          include_examples 'it creates a message in a new conversation'
        end

        context "and the subject contains [✔]" do
          let(:expect_conversation_to_be_a_task){ true }
          let(:subject){ "[✔] pickup some fried chicken" }
          let(:expected_conversation_subject){ "pickup some fried chicken" }
          let(:expected_sent_email_subject){ "[✔][RaceTeam] pickup some fried chicken" }
          let(:expected_smtp_envelope_from){ 'raceteam+task@127.0.0.1' }
          include_examples 'it creates a message in a new conversation'
        end

      end

      context "and the sender is not a covered member" do
        include_context 'the sender is not a covered member'

        context "and the from address is not a project member" do
          include_examples 'it bounces the message'
        end

        context "but the from address is a project member" do
          include_context 'the from address is a project member'
          include_examples 'it creates a message in a new conversation'
        end
      end

      context "and the sender is a covered member who is not a project member" do
        include_context 'the sender is a covered member who is not a project member'

        context "and the from address is not a project member" do
          include_examples 'it bounces the message'
        end

        context "but the from address is a project member" do
          include_context 'the from address is a project member'
          include_examples 'it creates a message in a new conversation'
        end
      end

      # include_context "when this message has CC recipients"
      # include_context "when the message has multiple recipients in the to header"
    end

    context 'and the subject is more than 255 characters' do
      include_context 'the sender is a project member'
      include_context 'it creates a message in a new conversation'
      let(:subject){ '1'*500 }
      let(:expected_conversation_subject){ '1'*255 }
      let(:expected_message_subject     ){ '1'*255 }
      let(:expected_sent_email_subject  ){ "[RaceTeam] #{'1'*255}" }
    end
  end

end
