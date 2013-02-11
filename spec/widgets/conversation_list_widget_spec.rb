require 'spec_helper'

describe ConversationListWidget do

  let(:project_conversations) { double(:project_conversations) }
  let(:project)               { double(:project, conversations: project_conversations) }
  let(:custom_conversations)  { double(:custom_conversations) }
  let(:arguments)             { [project] }

  def html_options
    {class: 'custom_class'}
  end

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        project: project,
        conversations: project_conversations,
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
          project: project,
          conversations: custom_conversations,
        }
      end
    end
  end

  describe "html_options" do
    it "should return the expected hash" do
      subject.html_options.should == {
        class: "conversation_list custom_class",
      }
    end
  end

end
