require 'spec_helper'

describe Covered::Messages::Create do

  let(:messages){ double :messages, covered: covered }
  let(:project){ double :project, id: 4855, name: 'Babys First Project' }
  let(:conversation_record){ double :conversation_record, messages: double(:messages)}
  let(:attachments){ double :attachments, present?: true }

  let :conversation do
    double(:conversation,
      covered: covered,
      conversation_record: conversation_record,
      project: project,
      subject: 'I like your face',
      task?: false,
      id: 1234,
    )
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

  before do
    Mail.stub random_tag: '529695e5b8b3a_13b723fe73985e6d876688'
    Timecop.freeze Time.parse('October 26th 1985 1:22 AM PDT')

    expect(Covered::Message).to receive(:new).
      with(covered, message_record).and_return(message)

    expect(message_record).to receive(:attachments=).with(attachments)
  end

  context "when not given a date" do
    it "sends the message with the expected data, and tracks that it was done" do

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

      expect(covered).to receive(:track).with('Composed Message', {
        'Project' => project.id,
        'Conversation' => conversation.id,
        'Project Name' => project.name,
        'Reply' => false,
        'Task' => false,
        'Via' => 'email',
        'Message ID' => expected_message_id_header,
      })

      return_value = described_class.call(messages,
        conversation: conversation,
        body: '<p>hi there</p>',
        attachments: attachments,
      )

      expect(return_value).to eq(message)
    end
  end

end
