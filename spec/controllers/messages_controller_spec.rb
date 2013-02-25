require 'spec_helper'

describe MessagesController do

  let(:project){ Project.first }
  let(:current_user){ project.members.first }
  let!(:conversation) { FactoryGirl.create(:conversation, project: project) }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in current_user
  end

  def valid_params
    {
      conversation_id: conversation.slug,
      project_id: project.slug
    }
  end

  describe "POST create" do
    let(:message) { FactoryGirl.build(:message, conversation: conversation) }
    let(:valid_attributes) do
      message.attributes.reject{
          |key, _| ! Message.accessible_attributes.include?(key)
      }
    end

    it "creates a new Message" do
      expect {
        xhr :post, :create, valid_params.merge(message: valid_attributes)
      }.to change(conversation.messages, :count).by(1)
      response.status.should == 201
    end

    it "enqueues emails for members" do
      SendConversationMessageWorker.any_instance.stub(:enqueue)
      SendConversationMessageWorker.should_receive(:enqueue).exactly(5).times

      xhr :post, :create, valid_params.merge(message: valid_attributes)
    end
  end
end

