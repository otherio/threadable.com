require 'spec_helper'

describe EmailProcessor::ParentMessageFinder do

  let(:project){ Project.find_by_slug!('ucsd-electric-racing') }
  let(:conversation){ project.conversations.last }
  let(:headers){ {'In-Reply-To' => in_reply_to, 'References' => references } }

  let(:parent_message){ create(:message, conversation: conversation) }

  def self.it_should_find_the_parent_message!
    it "should find the parent message" do
      message = EmailProcessor::ParentMessageFinder.call(project.id, headers)
      expect(message).to eql parent_message
    end
  end

  context "when there is a valid message id header in the In-Replt-To header" do
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
    let(:other_message){ create(:message, conversation: conversation) }
    it_should_find_the_parent_message!
  end

  context "when there is not a valid message id header in the In-Replt-To header or the References header" do
    let(:in_reply_to){ "abcd" }
    let(:references ){ "efgh ijkl mnop" }
    it "should not find a parent message" do
      message = EmailProcessor::ParentMessageFinder.call(project.id, headers)
      expect(message).to be_nil
    end
  end

end
