require 'spec_helper'

describe Covered::Messages::FindByChildHeader do

  let(:project_id){ 9331 }

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

  def expect_query references, messages
    scope = double(:scope)
    expect(Message).to receive(:joins).with(:conversation => :project).and_return(scope)
    expect(scope).to receive(:where).with(
      :projects => { :id => project_id },
      :messages => { :message_id_header => references },
    ).and_return(scope)
    expect(scope).to receive(:to_a).and_return(messages)
  end

  delegate :call, to: :described_class

  context 'when the In-Reply-To and References headers are blank' do
    let(:in_reply_to_header){ stringable("") }
    let(:references_header ){ stringable("") }
    it "returns nil" do
      expect( call(project_id, header) ).to be_nil
    end
  end


  context 'when the References header and the In-Reply-To header both contain different valid message ids' do
    let(:references        ){ ['<aaaaaa@gmail.com>', '<bbbbbb@gmail.com>','<cccccc@gmail.com>','<dddddd@gmail.com>'] }
    let(:in_reply_to_header){ stringable(references.first             ) }
    let(:references_header ){ stringable(references.last(3).reverse.join(' ') ) }
    let(:messages){ references.map{|reference| double(:message, message_id_header: reference) } }
    it "returns the parent message" do
      expect_query(references, messages.shuffle)
      expect( call(project_id, header) ).to eq messages.first
    end
  end

end
