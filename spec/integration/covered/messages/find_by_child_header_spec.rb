require 'spec_helper'

describe Covered::Messages::FindByChildHeader do

  let(:project){ covered.projects.find_by_slug! 'raceteam' }

  let :header do
    {
      'In-Reply-To' => in_reply_to_header,
      'References'  => references_header,
    }
  end

  def stringable string
    stringable = double(:stringable)
    expect(stringable).to receive(:to_s).and_return(string)
    stringable
  end

  delegate :call, to: :described_class

  context 'when the In-Reply-To and References headers are blank' do
    let(:in_reply_to_header){ stringable("") }
    let(:references_header ){ stringable("") }
    it "returns nil" do
      expect( call(project.id, header) ).to be_nil
    end
  end

  context 'when the In-Reply-To header matches a message in this project' do
    let(:parent_message    ){ project.messages.latest }
    let(:in_reply_to_header){ stringable(parent_message.message_id_header) }
    let(:references_header ){ stringable("") }
    it "returns the parent message" do
      expect( call(project.id, header) ).to eq parent_message.message_record
    end
  end

  context 'when the References header contains a message in this project' do
    let(:parent_message    ){ project.messages.latest }
    let(:in_reply_to_header){ stringable("") }
    let(:references_header ){ stringable(parent_message.message_id_header) }
    it "returns the parent message" do
      expect( call(project.id, header) ).to eq parent_message.message_record
    end
  end

  context 'when the References header and the In-Reply-To header both contain different valid message ids' do
    let(:conversation){ project.conversations.find_by_slug('layup-body-carbon') }
    let(:parent_message1   ){ conversation.messages.latest }
    let(:parent_message2   ){ conversation.messages.oldest }
    let(:in_reply_to_header){ stringable(parent_message1.message_id_header) }
    let(:references_header ){ stringable(parent_message2.message_id_header) }
    it "returns the parent message" do
      expect(parent_message2).to_not eq parent_message1
      expect( call(project.id, header) ).to eq parent_message1.message_record
    end
  end

end
