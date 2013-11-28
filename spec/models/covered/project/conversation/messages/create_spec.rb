require 'spec_helper'

describe Covered::Project::Conversation::Messages::Create do

  let(:project){ double :project, id: 4855 }
  let(:conversation_record){ double :conversation_record, messages: double(:messages)}

  let :conversation do
    double(:conversation,
      covered: covered,
      conversation_record: conversation_record,
      project: project,
      subject: 'I like your face',
    )
  end

  before do
    Mail.stub random_tag: '529695e5b8b3a_13b723fe73985e6d876688'
    Timecop.freeze Time.parse('October 26th 1985 1:22 AM PST')

    expect(message_record).to receive(:attachments=)

    expect(Covered::Project::Conversation::Message).to receive(:new).
      with(conversation, message_record).and_return(message)
  end

  let(:expected_parent_message_id)  { nil }
  let(:expected_subject)            { 'I like your face' }
  let(:expected_from)               { nil }
  let(:expected_creator_id)         { nil }
  let(:expected_body_plain)         { 'hi there' }
  let(:expected_body_html)          { '<p>hi there</p>' }
  let(:expected_stripped_plain)     { nil }
  let(:expected_stripped_html)      { nil }
  let(:expected_message_id_header)  { "<529695e5b8b3a_13b723fe73985e6d876688@127.0.0.1>" }
  let(:expected_references_header)  { nil }
  let(:expected_date_header)        { "Sat, 26 Oct 1985 08:22:00 -0000" }

  let(:message_record){ double :message_record }
  let(:message){ double :message, persisted?: true, recipients: [] }


  context "when not given a date" do
    it "sets the message date to now in the rfc2822 format" do

      expect(conversation_record.messages).to receive(:create).with(
        parent_message_id: expected_parent_message_id,
        subject:           expected_subject,
        from:              expected_from,
        creator_id:        expected_creator_id,
        body_plain:        expected_body_plain,
        body_html:         expected_body_html,
        stripped_plain:    expected_stripped_plain,
        stripped_html:     expected_stripped_html,
        message_id_header: expected_message_id_header,
        references_header: expected_references_header,
        date_header:       expected_date_header,
      ).and_return(message_record)

      expect( described_class.call(conversation, body: '<p>hi there</p>') ).to eq(message)
    end
  end

end
