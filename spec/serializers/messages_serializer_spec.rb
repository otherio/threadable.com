require 'spec_helper'

describe MessagesSerializer do

  let(:raceteam) { threadable.organizations.find_by_slug!('raceteam') }
  let(:sfhealth) { threadable.organizations.find_by_slug!('sfhealth') }
  let(:conversation){ raceteam.conversations.find_by_slug!('welcome-to-our-threadable-organization') }
  let(:message) { conversation.messages.latest }
  let(:message2) { conversation.messages.all.first }

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  context 'when given a single record' do
    let(:payload){ message }
    let(:expected_key){ :message }
    let :expected_return_value do
      {
        id:                message.id,
        unique_id:         message.unique_id,
        from:              "Bethany Pattern <bethany@ucsd.example.com>",
        subject:           "Welcome to our Threadable organization!",

        body:              "Yay! You go Alice. This tool looks radder than an 8-legged panda.",
        body_stripped:     "Yay! You go Alice. This tool looks radder than an 8-legged panda.",

        message_id_header: message.message_id_header,
        references_header: message.references_header,
        date_header:       message.date_header,

        html:              false,
        root:              false,
        shareworthy:       false,
        knowledge:         false,
        created_at:        message.created_at,
        sent_at:           message.sent_at,
        sent_to_you:       true,

        avatar_url:        '/fixture_images/bethany.jpg',
        sender_name:       'Bethany Pattern',

        parent_message_id: message.parent_message_id,
        attachments:       [],
      }
    end
    it do
      is_expected.to eq expected_return_value
    end
    context 'when given the option include: :conversation' do
      let(:options){ {include: :conversation} }
      it do
        is_expected.to eq expected_return_value.merge serialize_model(:conversations, message.conversation)
      end
    end
  end

  context 'with attachments' do
    let(:conversation){ raceteam.conversations.find_by_slug!('how-are-we-paying-for-the-motor-controller') }
    let(:payload){ message }
    let(:expected_key){ :message }
    it 'has attachments' do
      attachments = subject[:attachments].sort_by{|a| a[:filename] }

      expect(attachments.length).to eq 3

      expect(attachments[0][:url]     ).to match /some\.gif$/
      expect(attachments[0][:filename]).to eq    "some.gif"
      expect(attachments[0][:mimetype]).to eq    "image/gif"
      expect(attachments[0][:size]    ).to eq    1829
      expect(attachments[0][:inline]  ).to eq    false
      expect(attachments[1][:url]     ).to match /some\.jpg$/
      expect(attachments[1][:filename]).to eq    "some.jpg"
      expect(attachments[1][:mimetype]).to eq    "image/jpeg"
      expect(attachments[1][:size]    ).to eq    2974
      expect(attachments[1][:inline]  ).to eq    false
      expect(attachments[2][:url]     ).to match /some\.txt$/
      expect(attachments[2][:filename]).to eq    "some.txt"
      expect(attachments[2][:mimetype]).to eq    "text/plain"
      expect(attachments[2][:size]    ).to eq    35
      expect(attachments[2][:inline]  ).to eq    false
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [message,message2] }
    let(:expected_key){ :messages }
    it 'returns an array of serialized records' do
      is_expected.to eq [
        {
          id:                message.id,
          unique_id:         message.unique_id,
          from:              "Bethany Pattern <bethany@ucsd.example.com>",
          subject:           "Welcome to our Threadable organization!",

          body:              "Yay! You go Alice. This tool looks radder than an 8-legged panda.",
          body_stripped:     "Yay! You go Alice. This tool looks radder than an 8-legged panda.",

          message_id_header: message.message_id_header,
          references_header: message.references_header,
          date_header:       message.date_header,

          html:              false,
          root:              false,
          shareworthy:       false,
          knowledge:         false,
          created_at:        message.created_at,
          sent_at:           message.sent_at,
          sent_to_you:       true,

          avatar_url:        '/fixture_images/bethany.jpg',
          sender_name:       'Bethany Pattern',

          parent_message_id: message.parent_message_id,
          attachments:       [],
        },{
          id:                message2.id,
          unique_id:         message2.unique_id,
          from:              "Alice Neilson <alice@ucsd.example.com>",
          subject:           "Welcome to our Threadable organization!",

          body:              "Hey all! I think we should try this way to organize our conversation and work for the car. Thanks for joining up!",
          body_stripped:     "Hey all! I think we should try this way to organize our conversation and work for the car. Thanks for joining up!",

          message_id_header: message2.message_id_header,
          references_header: message2.references_header,
          date_header:       message2.date_header,

          html:              false,
          root:              true,
          shareworthy:       false,
          knowledge:         false,
          created_at:        message2.created_at,
          sent_at:           message2.sent_at,
          sent_to_you:       true,

          avatar_url:        '/fixture_images/alice.jpg',
          sender_name:       'Alice Neilson',

          parent_message_id: message2.parent_message_id,
          attachments:       [],
        }
      ]
    end
  end

end
