require 'spec_helper'

describe Threadable::IncomingEmail do

  let(:raceteam      ){ threadable.organizations.find_by_slug!('raceteam') }
  let(:alice         ){ raceteam.members.find_by_email_address!('alice@ucsd.example.com') }
  let(:incoming_email){ threadable.incoming_emails.create!(params) }
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
      creator: alice,
      subject: 'Where is my hammer?',
      attachments: attachments
    )
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
      expect( incoming_email.message.body_html         ).to eq params['body-html']
      expect( incoming_email.message.stripped_plain    ).to eq params['stripped-text']
      expect( incoming_email.message.stripped_html     ).to eq params['stripped-html']
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
        Storage.stub local?: false

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
  end

end
