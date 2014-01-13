require 'spec_helper'

describe Api::MessagesSerializer do

  let(:raceteam) { covered.organizations.find_by_slug!('raceteam') }
  let(:sfhealth) { covered.organizations.find_by_slug!('sfhealth') }
  let(:conversation){ raceteam.conversations.find_by_slug!('welcome-to-our-covered-organization') }
  let(:message) { conversation.messages.latest }
  let(:message2) { conversation.messages.all.first }

  context 'when given a single record' do
    let(:payload){ message }
    it do
      should eq(
        message: {
          id:                message.id,
          unique_id:         message.unique_id,
          from:              "Bethany Pattern <bethany@ucsd.example.com>",
          subject:           "Welcome to our Covered organization!",

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

          avatar_url:        '/fixture_images/bethany.jpg',
          sender_name:       'Bethany Pattern',

          parent_message_id: message.parent_message_id,
          attachments:       [],
        }
      )
    end
  end

  context 'with attachments' do
    let(:conversation){ raceteam.conversations.find_by_slug!('how-are-we-paying-for-the-motor-controller') }
    let(:payload){ message }
    it 'has attachments' do
      attachments = subject[:message][:attachments]

      expect(attachments.length).to eq 3

      expect(attachments[0][:url]).to match /some\.gif$/
      expect(attachments[0][:filename]).to eq 'some.gif'
      expect(attachments[0][:mimetype]).to eq 'image/gif'
      expect(attachments[0][:size]).to eq 1829
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [message,message2] }

    it 'foo' do
      should eq(
        messages: [
          {
            id:                message.id,
            unique_id:         message.unique_id,
            from:              "Bethany Pattern <bethany@ucsd.example.com>",
            subject:           "Welcome to our Covered organization!",

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

            avatar_url:        '/fixture_images/bethany.jpg',
            sender_name:       'Bethany Pattern',

            parent_message_id: message.parent_message_id,
            attachments:       [],
          },{
            id:                message2.id,
            unique_id:         message2.unique_id,
            from:              "Alice Neilson <alice@ucsd.example.com>",
            subject:           "Welcome to our Covered organization!",

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

            avatar_url:        '/fixture_images/alice.jpg',
            sender_name:       'Alice Neilson',

            parent_message_id: message2.parent_message_id,
            attachments:       [],
          }
        ]
      )
    end
  end

end
