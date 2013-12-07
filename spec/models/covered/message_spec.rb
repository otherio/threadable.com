require 'spec_helper'

describe Covered::Message do
  let(:body_html) { 'html body' }
  let(:body_plain) { 'text body' }

  let :message_record do
    double(:message_record, id: 5, body_html: body_html, body_plain: body_plain)
  end

  let(:message){ described_class.new(covered, message_record) }
  subject{ message }

  it { should delegate(:id                 ).to(:message_record) }
  it { should delegate(:unique_id          ).to(:message_record) }
  it { should delegate(:parent_message_id  ).to(:message_record) }
  it { should delegate(:conversation_id    ).to(:message_record) }
  it { should delegate(:to_param           ).to(:message_record) }
  it { should delegate(:from               ).to(:message_record) }
  it { should delegate(:subject            ).to(:message_record) }
  it { should delegate(:message_id_header  ).to(:message_record) }
  it { should delegate(:references_header  ).to(:message_record) }
  it { should delegate(:to_header          ).to(:message_record) }
  it { should delegate(:cc_header          ).to(:message_record) }
  it { should delegate(:date_header        ).to(:message_record) }
  it { should delegate(:shareworthy?       ).to(:message_record) }
  it { should delegate(:knowledge?         ).to(:message_record) }
  it { should delegate(:body_html          ).to(:message_record) }
  it { should delegate(:body_plain         ).to(:message_record) }
  it { should delegate(:stripped_html      ).to(:message_record) }
  it { should delegate(:stripped_plain     ).to(:message_record) }
  it { should delegate(:created_at         ).to(:message_record) }
  it { should delegate(:persisted?         ).to(:message_record) }
  it { should delegate(:errors             ).to(:message_record) }


  its(:covered){ should eq covered }
  its(:message_record){ should eq message_record }
  its(:inspect) { should eq %(#<#{message.class} message_id: #{message.id.inspect}>)}

  describe '#body' do
    subject{ message.body }

    shared_examples_for 'message body methods' do
      it 'returns the correct body' do
        expect(subject).to eq expected_body
      end

      it 'identifies itself as html/text' do
        expect(subject.html?).to eq expected_html?
      end
    end

    context 'with both a text and html body' do
      let(:expected_body) { 'html body' }
      let(:expected_html?) { true }
      include_examples 'message body methods'
    end

    context 'with just a text body' do
      let(:body_html) { nil }
      let(:body_plain) { 'text body' }

      let(:expected_body) { 'text body' }
      let(:expected_html?) { false }
      include_examples 'message body methods'
    end

    context 'with just an html body' do
      let(:body_html) { 'html body' }
      let(:body_plain) { nil }

      let(:expected_body) { 'html body' }
      let(:expected_html?) { true }
      include_examples 'message body methods'
    end

    context 'with a blank body' do
      let(:body_html) { nil }
      let(:body_plain) { nil }

      let(:expected_body) { '' }
      let(:expected_html?) { false }
      include_examples 'message body methods'
    end

  end

end
