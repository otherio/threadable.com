require 'spec_helper'

describe Threadable::IncomingEmail, :type => :request do

  let(:raceteam      ){ threadable.organizations.find_by_slug!('raceteam') }
  let(:alice         ){ raceteam.members.find_by_email_address!('alice@ucsd.example.com') }
  let(:incoming_email){ threadable.incoming_emails.create!(params).first }
  subject{ incoming_email }

  let :attachments do
    [
      RSpec::Support::Attachments.uploaded_file('some.gif', 'image/gif',  true),
      RSpec::Support::Attachments.uploaded_file('some.txt', 'text/plain', false),
    ]
  end

  let :params do
    create_incoming_email_params(
      organization: raceteam,
      subject: 'Where is my hammer?',
      attachments: attachments
    )
  end

  def clean_html body
    CorrectHtml.call(body)
  end

  def expect_delivered!
    incoming_email.process!

    expect(incoming_email.held?).to be_falsy
    expect(incoming_email.bounced?).to be_falsy
    expect(incoming_email.dropped?).to be_falsy
    expect(incoming_email.delivered?).to be_truthy
  end

  def expect_dropped!
    incoming_email.process!

    expect(incoming_email.held?).to be_falsy
    expect(incoming_email.bounced?).to be_falsy
    expect(incoming_email.dropped?).to be_truthy
    expect(incoming_email.delivered?).to be_falsy
  end

  def expect_bounced!
    incoming_email.process!

    expect(incoming_email.held?).to be_falsy
    expect(incoming_email.bounced?).to be_truthy
    expect(incoming_email.dropped?).to be_falsy
    expect(incoming_email.delivered?).to be_falsy
  end

  def expect_held!
    incoming_email.process!

    expect(incoming_email.held?).to be_truthy
    expect(incoming_email.bounced?).to be_falsy
    expect(incoming_email.dropped?).to be_falsy
    expect(incoming_email.delivered?).to be_falsy
  end

  describe 'process!' do
    it 'finds all associations and sends out the new message' do
      incoming_email.process!
      expect( incoming_email                 ).to be_processed
      expect( incoming_email                 ).to_not be_bounced
      expect( incoming_email                 ).to_not be_held
      expect( incoming_email.organization    ).to eq raceteam
      expect( incoming_email.creator         ).to be_the_same_user_as alice
      expect( incoming_email.parent_message  ).to be_nil
      expect( incoming_email.conversation    ).to be_a Threadable::Conversation
      expect( incoming_email.conversation    ).to eq incoming_email.message.conversation
      expect( incoming_email.subject         ).to eq 'Where is my hammer?'

      expect( incoming_email.message.creator           ).to be_the_same_user_as alice
      expect( incoming_email.message.message_id_header ).to eq params['Message-Id']
      expect( incoming_email.message.references_header ).to eq ""
      expect( incoming_email.message.date_header       ).to eq params['Date'].sub(%r{-0000}, '+0000')
      expect( incoming_email.message.subject           ).to eq 'Where is my hammer?'
      expect( incoming_email.message.parent_message    ).to be_nil
      expect( incoming_email.message.from              ).to eq alice.formatted_email_address
      expect( incoming_email.message.body_plain        ).to eq params['body-plain']
      expect( incoming_email.message.body_html         ).to eq clean_html(params['body-html'])
      expect( incoming_email.message.stripped_plain    ).to eq params['stripped-text']
      expect( incoming_email.message.stripped_html     ).to eq clean_html(params['stripped-html'])
      expect( incoming_email.message.attachments       ).to be_a Threadable::Message::Attachments
      expect( incoming_email.message.attachments.count ).to eq 2

      attachments = incoming_email.message.attachments.all

      expect( attachments[0].filename ).to eq 'some.gif'
      expect( attachments[0].mimetype ).to eq 'image/gif'
      expect( attachments[0].url      ).to end_with 'some.gif'
      expect( attachments[1].filename ).to eq 'some.txt'
      expect( attachments[1].mimetype ).to eq 'text/plain'
      expect( attachments[1].url      ).to end_with 'some.txt'

      expect(described_class::Process).to_not receive(:call)
      incoming_email.process!
    end

    context 'when Storage.local? is false' do
      before do
        allow(Storage).to receive_messages local?: false

        expect(FilepickerUploader).to receive(:upload){|file|
          expect( file.original_filename ).to eq 'some.gif'
          expect( file.content_type      ).to eq 'image/gif'
          expect( file.io.read           ).to eq attachments[0].tap(&:rewind).read
          self
        }.and_return(
          "url"      => '/fake_url/some.gif',
          "filename" => 'some.gif',
          "type"     => 'image/gif',
          "size"     => '1234',
        )

        expect(FilepickerUploader).to receive(:upload){|file|
          expect( file.original_filename ).to eq 'some.txt'
          expect( file.content_type      ).to eq 'text/plain'
          expect( file.io.read           ).to eq attachments[1].tap(&:rewind).read
          self
        }.and_return(
          "url"      => '/fake_url/some.txt',
          "filename" => 'some.txt',
          "type"     => 'text/plain',
          "size"     => '88',
        )

      end
      it 'stores attachments using filepicker' do
        incoming_email.process!

        attachments = incoming_email.message.attachments.all

        expect( attachments[0].url      ).to eq '/fake_url/some.gif'
        expect( attachments[0].filename ).to eq 'some.gif'
        expect( attachments[0].mimetype ).to eq 'image/gif'
        expect( attachments[1].url      ).to eq '/fake_url/some.txt'
        expect( attachments[1].filename ).to eq 'some.txt'
        expect( attachments[1].mimetype ).to eq 'text/plain'
      end
    end

    describe 'mail holding' do
      let (:from) { 'Barth Rowesly <rowesly@gmail.com>' }
      let (:envelope_from) {'rowesly@gmail.com'}

      let :params do
        create_incoming_email_params(
          {
            organization: raceteam,
            from: from,
            envelope_from: envelope_from,
            subject: 'Re: Cars are real',
          }.merge(test_params)
        )
      end

      context 'when the organization holds all messages' do
        before do
          raceteam.organization_record.update_attributes(hold_all_messages: true)
          raceteam.reload
        end

        context 'when the sender is not an org member' do
          context 'when the message is a reply' do
            let(:parent_message) { raceteam.conversations.last.messages.last }
            let(:test_params) { {in_reply_to: parent_message.message_id_header} }

            it 'delivers the message' do
              expect_delivered!
            end

            context 'when all of the groups hold messages from non-members' do
              before do
                raceteam.groups.primary.group_record.update_attributes(non_member_posting: :hold)
              end

              it 'holds the message' do
                expect_held!
              end
            end
          end

          context 'when the message starts a new conversation' do
            let(:test_params) { {subject: 'Cars are super real, hyperreal even.'} }

            it 'holds the message' do
              expect_held!
            end
          end

        end

        context 'when the sender is an org member' do
          let (:from) { 'Nadya Leviticon <nadya@ucsd.example.com>' }
          let (:envelope_from) {'nadya@ucsd.example.com'}

          context 'when the message is a reply' do
            let(:parent_message) { raceteam.conversations.last.messages.last }
            let(:test_params) { {in_reply_to: parent_message.message_id_header} }

            it 'delivers the message' do
              expect_delivered!
            end

            context 'when all of the groups hold messages from non-members' do
              before do
                raceteam.groups.primary.group_record.update_attributes(non_member_posting: :hold)
              end

              it 'delivers the message' do
                expect_delivered!
              end
            end
          end

          context 'when the message starts a new conversation' do
            let(:test_params) { {subject: 'Cars are super real, hyperreal even.'} }

            it 'holds the message' do
              expect_held!
            end
          end
        end

        context 'when the sender is an owner' do
          let (:from) { 'Alice Neilson <alice@ucsd.example.com>' }
          let (:envelope_from) {'alice@ucsd.example.com'}


          context 'when the message is a reply' do
            let(:parent_message) { raceteam.conversations.last.messages.last }
            let(:test_params) { {in_reply_to: parent_message.message_id_header} }

            it 'delivers the message' do
              expect_delivered!
            end

            context 'when all of the groups hold messages from non-members' do
              before do
                raceteam.groups.primary.group_record.update_attributes(non_member_posting: :hold)
              end

              it 'delivers the message' do
                expect_delivered!
              end
            end
          end

          context 'when the message starts a new conversation' do
            let(:test_params) { {subject: 'Cars are super real, hyperreal even.'} }

            it 'delivers the message' do
              expect_delivered!
            end
          end
        end
      end

      context 'when the organization does not hold all messages' do
        context 'when the sender is not an org member' do
          context 'when the message is a reply' do
            let(:parent_message) { raceteam.conversations.last.messages.last }
            let(:test_params) { {in_reply_to: parent_message.message_id_header} }

            context 'when any of the groups permit non-member replies' do
              before do
                raceteam.groups.primary.group_record.update_attributes(non_member_posting: :allow_replies)
              end

              it 'delivers the message' do
                expect_delivered!
              end
            end

            context 'when any of the groups allow new conversations from non-members' do
              before do
                raceteam.groups.primary.group_record.update_attributes(non_member_posting: :allow)
              end

              it 'delivers the message' do
                expect_delivered!
              end
            end

            context 'when all of the groups hold messages from non-members' do
              before do
                raceteam.groups.primary.group_record.update_attributes(non_member_posting: :hold)
              end

              it 'holds the message' do
                expect_held!
              end
            end
          end

          context 'when the message starts a new conversation' do
            let :params do
              create_incoming_email_params(
                organization: raceteam,
                from: 'Barth Rowesly <rowesly@gmail.com>',
                envelope_from: 'rowesly@gmail.com',
                subject: 'I love cars! Can I car your cars with you?'
              )
            end

            context 'when all of the groups allow replies but not new conversations' do
              before do
                raceteam.groups.primary.group_record.update_attributes(non_member_posting: :allow_replies)
              end

              it 'delivers the message' do
                expect_held!
              end
            end

            context 'when all of the groups hold messages from non-members' do
              before do
                raceteam.groups.primary.group_record.update_attributes(non_member_posting: :hold)
              end

              it 'holds the message' do
                expect_held!
              end
            end

            context 'when any of the groups allow new conversations from non-members' do
              before do
                raceteam.groups.primary.group_record.update_attributes(non_member_posting: :allow)
              end

              it 'delivers the message' do
                expect_delivered!
              end
            end
          end
        end
      end
    end

    describe 'spam handling for held messages' do
      context 'when the sender is not an org member' do
        let :params do
          create_incoming_email_params(
            organization: raceteam,
            from: 'Spam Emporium <spam@emp.ru>',
            envelope_from: 'spam@emp.ru',
            subject: 'ROLEX VIAGRA 4 U!!1!',
            spam_score: 23.2
          )
        end

        it 'drops the spam' do
          expect_dropped!
        end
      end

      context 'when the sender is not an org member, and the mailgun spam check failed' do
        let :params do
          create_incoming_email_params(
            organization: raceteam,
            from: 'Spam Emporium <spam@emp.ru>',
            envelope_from: 'spam@emp.ru',
            subject: 'ROLEX VIAGRA 4 U!!1!',
            spam_score: 0.0
          )
        end

        before do
          # testing this all the way through, since it uncovers a very special bug.
          stub_request(:post, 'http://spamcheck.postmarkapp.com/filter').to_return(
            body: {success: true, score: 23.2}.to_json,
            headers: {'Content-type' => 'application/json'},
            status: 200,
          )
        end

        it 'drops the spam' do
          expect_dropped!
        end
      end

      context 'when the sender is not an org member, and the message is not spam' do
        let :params do
          create_incoming_email_params(
            organization: raceteam,
            from: 'Jefferson McKinley <jeff@things.io>',
            envelope_from: 'jeff@things.io',
            subject: 'Right-o, let us do this.',
            spam_score: 1.1
          )
        end

        it 'holds the message' do
          expect_held!
        end
      end

      context 'when the sender is an org member' do
        let :params do
          create_incoming_email_params(
            organization: raceteam,
            from: 'Alice Neilson <alice@ucsd.example.com>',
            envelope_from: 'alice@ucsd.example.com',
            subject: 'Have you seen these ROLEX VIAGRA 4 U!!1! emails? Crazy!',
            spam_score: 15.5
          )
        end

        it 'delivers the message' do
          expect_delivered!
        end
      end

    end
  end

end
