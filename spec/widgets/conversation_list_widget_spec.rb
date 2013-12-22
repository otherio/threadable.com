require 'spec_helper'

describe ConversationListWidget do

  let(:organization_conversations) { double(:organization_conversations) }
  let(:organization)               { double(:organization, conversations: double(:conversations, all_with_participants: organization_conversations) ) }
  let(:custom_conversations)  { double(:custom_conversations) }
  let(:arguments)             { [organization] }

  def html_options
    {class: 'custom_class'}
  end

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        organization: organization,
        conversations: organization_conversations,
      }
    end
    context "when given conversations" do
      def html_options
        {conversations: custom_conversations}
      end
      it do
        should == {
          block: nil,
          presenter: presenter,
          organization: organization,
          conversations: custom_conversations,
        }
      end
    end
  end

  describe "html_options" do
    it "should return the expected hash" do
      subject.html_options.should == {
        class: "conversation_list custom_class",
        widget: "conversation_list",
      }
    end
  end

end
