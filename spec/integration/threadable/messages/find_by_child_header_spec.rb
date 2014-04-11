require 'spec_helper'

describe Threadable::Messages::FindByChildHeader do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }

  let :header do
    {
      'In-Reply-To'  => in_reply_to_header,
      'References'   => references_header,
      'message-headers' => [['Thread-Index', thread_index_header]].to_json,
    }
  end

  def stringable string
    stringable = double(:stringable)
    expect(stringable).to receive(:to_s).and_return(string)
    stringable
  end

  delegate :call, to: :described_class

  let(:thread_index_header) { "" }

  context 'when the In-Reply-To and References headers are blank' do
    let(:in_reply_to_header){ stringable("") }
    let(:references_header ){ stringable("") }
    it "returns nil" do
      expect( call(organization.id, header) ).to be_nil
    end
  end

  context 'when the In-Reply-To header matches a message in this organization' do
    let(:parent_message    ){ organization.messages.latest }
    let(:in_reply_to_header){ stringable(parent_message.message_id_header) }
    let(:references_header ){ stringable("") }
    it "returns the parent message" do
      expect( call(organization.id, header) ).to eq parent_message.message_record
    end
  end

  context 'when the References header contains a message in this organization' do
    let(:parent_message    ){ organization.messages.latest }
    let(:in_reply_to_header){ stringable("") }
    let(:references_header ){ stringable(parent_message.message_id_header) }
    it "returns the parent message" do
      expect( call(organization.id, header) ).to eq parent_message.message_record
    end
  end

  context 'when the References header and the In-Reply-To header both contain different valid message ids' do
    let(:conversation){ organization.conversations.find_by_slug('layup-body-carbon') }
    let(:parent_message1   ){ conversation.messages.latest }
    let(:parent_message2   ){ conversation.messages.oldest }
    let(:in_reply_to_header){ stringable(parent_message1.message_id_header) }
    let(:references_header ){ stringable(parent_message2.message_id_header) }
    it "returns the parent message" do
      expect(parent_message2).to_not eq parent_message1
      expect( call(organization.id, header) ).to eq parent_message1.message_record
    end
  end

  context "when the parent message is identifed by the Thread-Index header" do
    let(:parent_message     ){ organization.messages.latest }
    let(:in_reply_to_header ){ stringable("") }
    let(:references_header  ){ stringable("") }
    let(:thread_index_header) { Base64.strict_encode64("#{parent_thread_index_decoded}67890") }

    let(:parent_thread_index_decoded) { "#{SecureRandom.uuid}12345" }

    before do
      parent_message.update(thread_index_header: Base64.strict_encode64(parent_thread_index_decoded))
    end

    it "returns the parent message" do
      expect( call(organization.id, header) ).to eq parent_message.message_record
    end

    context "when the parent message is identifed by a much older Thread-Index header" do
      let(:thread_index_header) { Base64.strict_encode64("#{parent_thread_index_decoded}678901234567890") }

      it "returns the parent message" do
        expect( call(organization.id, header) ).to eq parent_message.message_record
      end
    end
  end
end
