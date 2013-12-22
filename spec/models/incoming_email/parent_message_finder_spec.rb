require 'spec_helper'

describe IncomingEmail::ParentMessageFinder do

  let(:organization){ find_organization_by_slug('raceteam') }
  let(:conversation){ organization.conversations.where(slug: 'layup-body-carbon').first! }
  let(:parent_message){ conversation.messages.where('messages.parent_id IS NOT NULL').last! }
  let(:headers){ {'In-Reply-To' => in_reply_to, 'References' => references } }

  before{ expect(parent_message.message_id_header).to be_present }

  def call!
    described_class.call(organization_id: organization.id, headers: headers)
  end

  def self.it_should_find_the_parent_message!
    it "should find the parent message" do
      expect(call!).to eql parent_message
    end
  end

  context "when there is a valid message id header in the In-Reply-To header" do
    let(:in_reply_to){ "abcd" }
    let(:references ){ "efgh #{parent_message.message_id_header} ijkl mnop" }
    it_should_find_the_parent_message!
  end

  context "when there is a valid message id header in the References header" do
    let(:in_reply_to){ "#{parent_message.message_id_header}" }
    let(:references ){ "efgh abcd ijkl mnop" }
    it_should_find_the_parent_message!
  end

  context "when there is a valid message id header in the In-Replt-To header and the References header" do
    let(:in_reply_to){ "#{parent_message.message_id_header}" }
    let(:references ){ "efgh #{other_message.message_id_header} ijkl mnop" }
    let(:other_message){ conversation.messages.where('messages.parent_id IS NOT NULL').first! }
    before{ expect(other_message.message_id_header).to be_present }
    it_should_find_the_parent_message!
  end

  context "when there is not a valid message id header in the In-Replt-To header or the References header" do
    let(:in_reply_to){ "abcd" }
    let(:references ){ "efgh ijkl mnop" }
    it "should not find a parent message" do
      expect(call!).to be_nil
    end
  end

end
