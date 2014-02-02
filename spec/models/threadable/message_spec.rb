require 'spec_helper'

describe Threadable::Message do
  let(:body_html) { 'html body' }
  let(:body_plain) { 'text body' }

  let :message_record do
    double(:message_record, id: 5, body_html: body_html, body_plain: body_plain)
  end

  let(:message){ described_class.new(threadable, message_record) }
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
  it { should delegate(:shareworthy?       ).to(:message_record) }
  it { should delegate(:knowledge?         ).to(:message_record) }
  it { should delegate(:body_html          ).to(:message_record) }
  it { should delegate(:body_plain         ).to(:message_record) }
  it { should delegate(:stripped_html      ).to(:message_record) }
  it { should delegate(:stripped_plain     ).to(:message_record) }
  it { should delegate(:created_at         ).to(:message_record) }
  it { should delegate(:persisted?         ).to(:message_record) }
  it { should delegate(:errors             ).to(:message_record) }


  its(:threadable){ should eq threadable }
  its(:message_record){ should eq message_record }
  its(:inspect) { should eq %(#<#{message.class} message_id: #{message.id.inspect}>)}

  describe '#date_header' do
    context 'when message_record.date_header is present' do
      before{ expect(message_record).to receive(:date_header).and_return('Wed, 15 Jan 2014 15:05:22 -0800') }
      it 'returns message_record.date_header' do
        expect(message.date_header).to eq 'Wed, 15 Jan 2014 15:05:22 -0800'
      end
    end
    context 'when message_record.date_header is blank' do
      let(:created_at){ Time.now }
      before do
        expect(message_record).to receive(:date_header).and_return(nil)
        expect(message_record).to receive(:created_at).and_return(created_at)
      end
      it 'returns message_record.date_header' do
        expect(message.date_header).to eq created_at.rfc2822
      end
    end
  end

  describe '#sent_at' do
    it 'returns a parsed Time of the date_header string' do
      expect(message_record).to receive(:date_header).and_return('Wed, 15 Jan 2014 15:05:22 -0800')
      expect(message.sent_at).to eq Time.parse('Wed, 15 Jan 2014 15:05:22 -0800')
    end
  end

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
