require 'spec_helper'

describe Covered::IncomingEmail::Process do

  let(:raceteam      ){ covered.projects.find_by_slug!('raceteam') }
  let(:alice         ){ raceteam.members.find_by_email_address!('alice@ucsd.covered.io') }
  let(:params        ){ create_incoming_email_params(create_incoming_email_params_options) }
  let(:incoming_email){ covered.incoming_emails.create!(params) }

  def create_incoming_email_params_options
    {
      subject: "who took my soldering iron?",
      date: Time.parse("Sun, 08 Dec 2013 14:57:02 -0800"),
    }
  end

  context 'when given a incoming email that has already been processed' do
    it 'raises and error' do
      expect(incoming_email).to receive(:processed?).and_return(true)
      expect{ incoming_email.process! }.to raise_error(ArgumentError, "IncomingEmail #{incoming_email.id.inspect} was already processed. Call reset! first.")
    end
  end

  context 'when given a incoming email that has not been processed' do
    it 'processes successfully' do
      expect( incoming_email.process! ).to be_true
      expect( incoming_email ).to be_processed
      expect( incoming_email ).to_not be_failed
      expect( incoming_email ).to_not be_reply
      expect( incoming_email ).to_not be_task
    end

    context 'when the incoming email is a reply' do
      let(:parent_message){ raceteam.messages.latest }
      def create_incoming_email_params_options
        super.merge(in_reply_to_header: parent_message.message_id_header)
      end
      it 'processes successfully' do
        expect( incoming_email.process! ).to be_true
        expect( incoming_email ).to be_processed
        expect( incoming_email ).to_not be_failed
        expect( incoming_email ).to be_reply
        expect( incoming_email ).to_not be_task
        expect( incoming_email.parent_message ).to eq parent_message
      end

      context 'that is already associated with the incoming_email' do
        before{ incoming_email.parent_message_id = parent_message.id }
        it 'processes successfully' do
          expect( incoming_email.process! ).to be_true

          expect( incoming_email ).to be_persisted
          expect( incoming_email ).to be_processed
          expect( incoming_email ).to_not be_failed
          expect( incoming_email ).to be_reply
          expect( incoming_email ).to_not be_task

          expect( incoming_email.subject              ).to eq "who took my soldering iron?"
          expect( incoming_email.message.subject      ).to eq "who took my soldering iron?"
          expect( incoming_email.conversation         ).to eq parent_message.conversation
          expect( incoming_email.parent_message       ).to eq parent_message
          expect( incoming_email.conversation.subject ).to eq parent_message.conversation.subject
          expect( incoming_email.project              ).to eq raceteam
          expect( incoming_email.creator              ).to be_the_same_user_as alice
          expect( incoming_email.message              ).to be_present
          expect( incoming_email.conversation         ).to be_a Covered::Conversation
          expect( incoming_email.conversation         ).to eq parent_message.conversation
          expect( incoming_email.parent_message       ).to eq parent_message
          expect( incoming_email.attachments.count    ).to eq 3

          expect( incoming_email.message.creator           ).to be_the_same_user_as alice
          expect( incoming_email.message.conversation      ).to eq parent_message.conversation
          expect( incoming_email.message.message_id_header ).to be_present
          expect( incoming_email.message.references_header ).to be_blank
          expect( incoming_email.message.date_header       ).to eq "Sun, 08 Dec 2013 14:57:02 -0800"
          expect( incoming_email.message.subject           ).to eq "who took my soldering iron?"
          expect( incoming_email.message.parent_message    ).to eq parent_message
          expect( incoming_email.message.from              ).to eq "Alice Neilson <alice@ucsd.covered.io>"
          expect( incoming_email.message.body_plain        ).to eq params["body-plain"]
          expect( incoming_email.message.body_html         ).to eq params["body-html"]
          expect( incoming_email.message.stripped_html     ).to eq params["stripped-html"]
          expect( incoming_email.message.stripped_plain    ).to eq params["stripped-text"]
          expect( incoming_email.message.attachments.count ).to eq 3
        end
      end

    end

    context 'when the incoming_email is a task' do
      def create_incoming_email_params_options
        super.merge(subject: "[✔] buy some milk")
      end
      it 'processes successfully' do
        expect( incoming_email.process! ).to be_true

        expect( incoming_email ).to be_persisted
        expect( incoming_email ).to be_processed
        expect( incoming_email ).to_not be_failed
        expect( incoming_email ).to_not be_reply
        expect( incoming_email ).to be_task

        expect( incoming_email.subject              ).to eq "[✔] buy some milk"
        expect( incoming_email.conversation.subject ).to eq "buy some milk"
        expect( incoming_email.conversation         ).to be_task
        expect( incoming_email.project              ).to eq raceteam
        expect( incoming_email.creator              ).to be_the_same_user_as alice
        expect( incoming_email.message              ).to be_present
        expect( incoming_email.conversation         ).to be_a Covered::Conversation
        expect( incoming_email.conversation         ).to eq incoming_email.message.conversation
        expect( incoming_email.parent_message       ).to be_nil
        expect( incoming_email.attachments.count    ).to eq 3

        expect( incoming_email.message.creator           ).to be_the_same_user_as alice
        expect( incoming_email.message.conversation      ).to be_a Covered::Conversation
        expect( incoming_email.message.conversation      ).to eq incoming_email.conversation
        expect( incoming_email.message.message_id_header ).to be_present
        expect( incoming_email.message.references_header ).to be_blank
        expect( incoming_email.message.date_header       ).to eq "Sun, 08 Dec 2013 14:57:02 -0800"
        expect( incoming_email.message.subject           ).to eq "[✔] buy some milk"
        expect( incoming_email.message.parent_message    ).to be_nil
        expect( incoming_email.message.from              ).to eq "Alice Neilson <alice@ucsd.covered.io>"
        expect( incoming_email.message.body_plain        ).to eq params["body-plain"]
        expect( incoming_email.message.body_html         ).to eq params["body-html"]
        expect( incoming_email.message.stripped_html     ).to eq params["stripped-html"]
        expect( incoming_email.message.stripped_plain    ).to eq params["stripped-text"]
        expect( incoming_email.message.attachments.count ).to eq 3
      end
    end

    context 'when the sender is not a member of the project' do
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
        expect( incoming_email.process! ).to be_true

        expect( incoming_email ).to be_persisted
        expect( incoming_email ).to be_processed
        expect( incoming_email ).to be_failed
        expect( incoming_email ).to_not be_reply

        expect( incoming_email.project           ).to eq raceteam
        expect( incoming_email.creator           ).to be_nil
        expect( incoming_email.conversation      ).to be_nil
        expect( incoming_email.parent_message    ).to be_nil
        expect( incoming_email.message           ).to be_nil
        expect( incoming_email.attachments.count ).to eq 3
      end

      context 'but its a reply to an existing message' do
        let(:parent_message){ raceteam.messages.latest }
        def create_incoming_email_params_options
          super.merge(in_reply_to_header: parent_message.message_id_header)
        end

        it 'processes successfully' do
          expect( incoming_email.process! ).to be_true

          expect( incoming_email ).to be_persisted
          expect( incoming_email ).to be_processed
          expect( incoming_email ).to_not be_failed
          expect( incoming_email ).to be_reply

          expect( incoming_email.project           ).to eq raceteam
          expect( incoming_email.creator           ).to be_nil
          expect( incoming_email.conversation      ).to eq parent_message.conversation
          expect( incoming_email.parent_message    ).to eq parent_message
          expect( incoming_email.message           ).to be_present
          expect( incoming_email.attachments.count ).to eq 3

          expect( incoming_email.message.creator           ).to be_nil
          expect( incoming_email.message.conversation      ).to be_a Covered::Conversation
          expect( incoming_email.message.conversation      ).to eq incoming_email.conversation
          expect( incoming_email.message.message_id_header ).to be_present
          expect( incoming_email.message.references_header ).to be_blank
          expect( incoming_email.message.date_header       ).to eq "Sun, 08 Dec 2013 14:57:02 -0800"
          expect( incoming_email.message.subject           ).to eq "who took my soldering iron?"
          expect( incoming_email.message.parent_message    ).to eq parent_message
          expect( incoming_email.message.from              ).to eq 'Larry Harvey <larry@bm.org>'
          expect( incoming_email.message.body_plain        ).to eq params["body-plain"]
          expect( incoming_email.message.body_html         ).to eq params["body-html"]
          expect( incoming_email.message.stripped_html     ).to eq params["stripped-html"]
          expect( incoming_email.message.stripped_plain    ).to eq params["stripped-text"]
          expect( incoming_email.message.attachments.count ).to eq 3
        end
      end

    end
  end

end
