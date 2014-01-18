require 'spec_helper'

describe Covered::Messages::FindByBodyReference do

  let(:organization){ covered.organizations.find_by_slug! 'raceteam' }

  let(:body){
    %(-- don't delete this: [ref: welcome-to-our-covered-organization]\n)+
    %(-- tip: control covered by putting commands at the top of your reply, just like this:\n\n)+
    %(&done\n)
  }

  delegate :call, to: :described_class

  context 'when the body contains our specific bullshit ref string' do
    let(:conversation){ organization.conversations.find_by_slug('welcome-to-our-covered-organization') }
    let(:parent_message   ){ conversation.messages.latest }

    it "returns the parent message" do
      expect( call(organization, body) ).to eq parent_message.message_record
    end
  end

  context 'when the body does not contains our specific bullshit ref string' do
    let(:conversation){ organization.conversations.find_by_slug('welcome-to-our-covered-organization') }
    let(:parent_message   ){ conversation.messages.latest }
    let(:body){
      %(do what you wanna do [ref: welcome-to-our-covered-organization]\n)+
      %(-- tip: control covered by putting commands at the top of your reply, just like this:\n\n)+
      %(&done\n)
    }

    it "returns nil" do
      expect( call(organization, body) ).to be_nil
    end
  end
end
