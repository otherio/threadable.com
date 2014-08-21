require 'spec_helper'

describe Threadable::Messages::Create, :type => :model do

  let(:messages){ double :messages, threadable: threadable }
  let(:organization){ double :organization, id: 4855, name: 'Babys First Organization' }
  let(:conversation_record){ double :conversation_record, messages: double(:messages)}
  let :attachment1 do
    {
      url:        'https://www.filepicker.io/api/file/fSCGhASDSADSAlyJLfmPU2tg',
      filename:   'whoa now.jpg',
      mimetype:   'image/jpeg',
      size:       '733',
      writeable:  'true',
      content_id: 'contentid',
      inline:     true,
    }
  end
  let :attachment2 do
    {
      url:        'https://www.filepicker.io/api/file/fSCGhYEITlyJLfmPU2tg',
      filename:   'working at the office_face0.jpg',
      mimetype:   'image/jpeg',
      size:       '7611',
      writeable:  'true',
      content_id: 'contentid',
      inline:     false,
    }
  end
  let(:attachment_record1){ double :attachment_record1 }
  let(:attachment_record2){ double :attachment_record2 }
  let(:attachments){ [attachment1, attachment2] }


  let :conversation do
    double(:conversation,
      threadable: threadable,
      conversation_record: conversation_record,
      organization: organization,
      subject: 'I like your face',
      task?: false,
      id: 1234,
      formatted_email_addresses: ['Foo Thing <foo@thing.com>'],
    )
  end

  let(:expected_parent_message_id)  { nil }
  let(:expected_subject)            { 'I like your face' }
  let(:expected_from)               { nil }
  let(:expected_creator_id)         { nil }
  let(:expected_body_plain)         { 'hi there' }
  let(:expected_body_html)          { '<p>hi there</p>' }
  let(:expected_stripped_plain)     { 'hi there' }
  let(:expected_stripped_html)      { '<p>hi there</p>' }
  let(:expected_message_id_header)  { "<529695e5b8b3a_13b723fe73985e6d876688@localhost>" }
  let(:expected_references_header)  { nil }
  let(:expected_date_header)        { "Sat, 26 Oct 1985 08:22:00 -0000" }
  let(:expected_to_header)          { "Foo Thing <foo@thing.com>" }
  let(:expected_cc_header)          { nil }

  let(:message_record) { double :message_record, created_at: Time.now }
  let(:message)        { double :message, persisted?: true, recipients: double(:recipients, all: []) }
  let(:latest_message) { nil }

  before do
    Mail.stub random_tag: '529695e5b8b3a_13b723fe73985e6d876688'
    Timecop.freeze Time.parse('October 26th 1985 1:22 AM PDT')

    expect(Threadable::Message).to receive(:new).
      with(threadable, message_record).and_return(message)

    expect(::Attachment).to receive(:create).with(attachment1).and_return(attachment_record1)
    expect(::Attachment).to receive(:create).with(attachment2).and_return(attachment_record2)

    conversation.stub_chain(:messages, :latest).and_return(latest_message)

    expect(message_record).to receive(:attachments=).with([attachment_record1, attachment_record2])
  end

  context "when not given a date" do
    it "sends the message with the expected data, and tracks that it was done" do

      expect(conversation_record.messages).to receive(:create).with(
        parent_message_id:   expected_parent_message_id,
        subject:             expected_subject,
        from:                expected_from,
        creator_id:          expected_creator_id,
        body_plain:          expected_body_plain,
        body_html:           expected_body_html,
        stripped_plain:      expected_stripped_plain,
        stripped_html:       expected_stripped_html,
        message_id_header:   expected_message_id_header,
        references_header:   expected_references_header,
        to_header:           expected_to_header,
        cc_header:           expected_cc_header,
        date_header:         expected_date_header,
        thread_index_header: nil,
        thread_topic_header: nil,
      ).and_return(message_record)

      expect(conversation).to receive(:update).with(last_message_at: message_record.created_at)
      expect(conversation).to receive(:update_participant_names_cache!)
      expect(conversation).to receive(:update_message_summary_cache!)

      expect(threadable).to receive(:track).with('Composed Message', {
        'Organization' => organization.id,
        'Conversation' => conversation.id,
        'Organization Name' => organization.name,
        'Reply' => false,
        'Task' => false,
        'Message ID' => expected_message_id_header,
      })

      expect(message).to receive(:send_emails!).with(false)

      return_value = described_class.call(messages,
        conversation: conversation,
        body: '<p>hi there</p>',
        attachments: attachments,
      )


      expect(return_value).to eq(message)
    end
  end

  context "when not given a parent message" do
    let(:latest_message) { double(
      :message,
      id: 235,
      references_header: "REFERENCES_HEADER_OMG",
      message_id_header: "MESSAGE_ID_HEADER_OMG"
    ) }

    let(:expected_parent_message_id) { 235 }
    let(:expected_references_header) { "REFERENCES_HEADER_OMG MESSAGE_ID_HEADER_OMG" }

    it "gets the parent message from the conversation" do

      expect(conversation_record.messages).to receive(:create).with(
        parent_message_id:   expected_parent_message_id,
        subject:             expected_subject,
        from:                expected_from,
        creator_id:          expected_creator_id,
        body_plain:          expected_body_plain,
        body_html:           expected_body_html,
        stripped_plain:      expected_stripped_plain,
        stripped_html:       expected_stripped_html,
        message_id_header:   expected_message_id_header,
        references_header:   expected_references_header,
        to_header:           expected_to_header,
        cc_header:           expected_cc_header,
        date_header:         expected_date_header,
        thread_index_header: nil,
        thread_topic_header: nil,
      ).and_return(message_record)

      expect(conversation).to receive(:update).with(last_message_at: message_record.created_at)
      expect(conversation).to receive(:update_participant_names_cache!)
      expect(conversation).to receive(:update_message_summary_cache!)

      expect(threadable).to receive(:track).with('Composed Message', {
        'Organization' => organization.id,
        'Conversation' => conversation.id,
        'Organization Name' => organization.name,
        'Reply' => true,
        'Task' => false,
        'Message ID' => expected_message_id_header,
      })

      expect(message).to receive(:send_emails!).with(false)

      return_value = described_class.call(messages,
        conversation: conversation,
        body: '<p>hi there</p>',
        attachments: attachments,
      )


      expect(return_value).to eq(message)
    end
  end

end
