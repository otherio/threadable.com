require 'spec_helper'

describe Covered::IncomingEmail::Process do

  let(:project       ){ covered.projects.find_by_slug!('raceteam') }
  let(:alice         ){ project.members.find_by_email_address!('alice@ucsd.covered.io') }
  let(:params        ){ create_incoming_email_params(create_incoming_email_params_options) }
  let(:incoming_email){ covered.incoming_emails.create!(params) }

  def create_incoming_email_params_options
    {
      subject: "who took my soldering iron?",
      date: Time.parse("Sun, 08 Dec 2013 14:57:02 -0800"),
    }
  end

  let(:expect_message_to_be_present         ){ true }
  let(:expect_incoming_email_to_be_processed){ true }
  let(:expect_incoming_email_to_be_failed   ){ false }
  let(:expected_to_be_a_reply               ){ false }
  let(:expected_to_be_a_task                ){ false }
  let(:expected_incoming_email_subject      ){ "who took my soldering iron?" }
  let(:expected_message_subject             ){ "who took my soldering iron?" }
  let(:expected_conversation_subject        ){ "who took my soldering iron?" }
  let(:expected_conversation                ){ nil }
  let(:expected_parent_message              ){ nil }
  let(:expected_references                  ){ "" }
  let(:expected_creator                     ){ alice }
  let(:expected_message_from                ){ "Alice Neilson <alice@ucsd.covered.io>" }
  let(:expected_via                         ){ 'email' }

  def assert_processed!

    if expect_incoming_email_to_be_failed
      expect(Honeybadger).to receive(:notify).with{|hash|
        expect(hash[:error_class]  ).to eq "incoming email process failed"
        expect(hash[:error_message]).to match %r(failed to find or create a conversation message for incoming email \d)
        expect(hash[:parameters][:incoming_email_id]).to be_a Integer
      }
    else
      expect(Honeybadger).to_not receive(:notify)
    end

    incoming_email.process!

    expect( incoming_email ).to be_persisted

    if expected_creator
      expect( covered.current_user ).to be_the_same_user_as expected_creator
    else
      expect( covered.current_user ).to be_nil
    end

    if expect_incoming_email_to_be_processed
      expect( incoming_email ).to be_processed
    else
      expect( incoming_email ).to_not be_processed
    end

    if expect_incoming_email_to_be_failed
      expect( incoming_email ).to be_failed
    else
      expect( incoming_email ).to_not be_failed
    end

    expect( incoming_email.attachments.count ).to eq 3

    if expected_to_be_a_reply
      expect( incoming_email ).to be_reply
    else
      expect( incoming_email ).to_not be_reply
    end

    if expected_to_be_a_task
      expect( incoming_email ).to be_task
    else
      expect( incoming_email ).to_not be_task
    end

    expect( incoming_email.subject         ).to eq expected_incoming_email_subject


    if expected_parent_message.present?
      expect( incoming_email.parent_message       ).to eq expected_parent_message
      expect( incoming_email.conversation         ).to eq expected_parent_message.conversation
      expect( incoming_email.message.conversation ).to eq expected_parent_message.conversation
    end

    if expected_conversation.present?
      expect( incoming_email.conversation         ).to eq expected_conversation
      expect( incoming_email.conversation.subject ).to eq expected_conversation_subject
    end

    expect( incoming_email.project              ).to eq project

    if expected_creator
      expect( incoming_email.creator         ).to be_the_same_user_as expected_creator
      expect( incoming_email.message.creator ).to be_the_same_user_as expected_creator
    else
      expect( incoming_email.creator ).to be_nil
    end

    if expect_message_to_be_present
      expect( incoming_email.message.subject ).to eq expected_message_subject
      expect( incoming_email.message.message_id_header ).to be_present
      expect( incoming_email.message.references_header ).to eq expected_references
      expect( incoming_email.message.date_header       ).to match /Sun, 08 Dec 2013 22:57:02 [-\+]0000/
      expect( incoming_email.message.subject           ).to eq expected_message_subject
      expect( incoming_email.message.parent_message    ).to eq expected_parent_message
      expect( incoming_email.message.from              ).to eq expected_message_from
      expect( incoming_email.message.body_plain        ).to eq params["body-plain"]
      expect( incoming_email.message.body_html         ).to eq params["body-html"]
      expect( incoming_email.message.stripped_html     ).to eq params["stripped-html"]
      expect( incoming_email.message.stripped_plain    ).to eq params["stripped-text"]
      expect( incoming_email.message.attachments.count ).to eq 3

      assert_tracked(expected_creator.try(:id), "Composed Message", {
        'Project'      => project.id,
        'Conversation' => incoming_email.conversation.id,
        'Project Name' => project.name,
        'Reply'        => expected_to_be_a_reply,
        'Task'         => expected_to_be_a_task,
        'Message ID'   => incoming_email.message.message_id_header,
      })
    else
      expect( incoming_email.message ).to_not be
    end
  end


  # tests:


  context 'when given a incoming email that has already been processed' do
    it 'raises and error' do
      expect(incoming_email).to receive(:processed?).and_return(true)
      expect{ incoming_email.process! }.to raise_error(ArgumentError, "IncomingEmail #{incoming_email.id.inspect} was already processed. Call reset! first.")
    end
  end

  context 'when given a incoming email that has not been processed' do
    it 'processes successfully' do
      assert_processed!
    end

    context 'when the incoming email is a reply' do
      let(:expected_parent_message        ){ project.messages.latest }
      let(:expected_to_be_a_reply         ){ true }
      let(:expected_to_be_a_task          ){ expected_parent_message.conversation.task? }
      let(:expected_incoming_email_subject){ "RE: your last email" }
      let(:expected_message_subject       ){ "RE: your last email" }
      let(:expected_conversation_subject  ){ expected_parent_message.conversation }
      let(:expected_conversation_subject  ){ expected_parent_message.conversation.subject }
      def create_incoming_email_params_options
        super.merge(
          subject: "RE: your last email",
          in_reply_to_header: expected_parent_message.message_id_header
        )
      end
      it 'processes successfully' do
        assert_processed!
      end
    end

    context 'when the incoming_email is a task' do
      let(:expected_to_be_a_task          ){ true }
      let(:expected_incoming_email_subject){ "[✔] buy some milk" }
      let(:expected_message_subject       ){ "[✔] buy some milk" }
      let(:expected_conversation_subject  ){ "buy some milk" }
      def create_incoming_email_params_options
        super.merge(subject: "[✔] buy some milk")
      end
      it 'processes successfully' do
        assert_processed!
      end
    end

    context 'when the sender is not a member of the project' do
      let(:expect_message_to_be_present         ){ false }
      let(:expect_incoming_email_to_be_processed){ true }
      let(:expect_incoming_email_to_be_failed   ){ true }
      let(:expected_creator                     ){ nil }
      let(:expected_message_from                ){ 'Larry Harvey <larry@bm.org>' }
      def create_incoming_email_params_options
        super.merge(
          envelope_from:      'larry@bm.org',
          from:               'Larry Harvey <larry@bm.org>',
          sender:             'larry@bm.org',
          in_reply_to_header: nil,
          references:         nil
        )
      end

      it 'processes unsuccessfully' do
        assert_processed!
      end

      context 'but its a reply to an existing message' do
        let(:expect_message_to_be_present       ){ true }
        let(:expect_incoming_email_to_be_failed ){ false }
        let(:expected_to_be_a_reply             ){ true }
        let(:expected_parent_message            ){ project.messages.latest }
        let(:expected_conversation_subject      ){ expected_parent_message.conversation }
        let(:expected_to_be_a_task              ){ expected_parent_message.conversation.task? }
        let(:expected_incoming_email_subject    ){ "RE: your last email" }
        let(:expected_message_subject           ){ "RE: your last email" }
        let(:expected_conversation_subject      ){ expected_parent_message.conversation.subject }
        def create_incoming_email_params_options
          super.merge(
            subject: "RE: your last email",
            in_reply_to_header: expected_parent_message.message_id_header,
          )
        end

        it 'processes successfully' do
          assert_processed!
        end
      end

    end
  end

end
