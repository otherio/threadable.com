require 'spec_helper'

describe ConversationMessagesWidget do

  let(:conversation) { double(:conversation) }
  let(:from_user)    { double(:from_user) }
  let(:arguments)    { [conversation] }

  def html_options
    {class: 'custom_class'}
  end

    describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        conversation: conversation,
        from: nil,
      }
    end
    context "when given the from user" do
      def html_options
        super.merge(from: from_user)
      end
      it do
        should == {
          block: nil,
          presenter: presenter,
          conversation: conversation,
          from: from_user,
        }
      end
    end
  end

  describe "html_options" do
    it "should return the expected hash" do
      subject.html_options.should == {
        class: "conversation_messages custom_class",
      }
    end
  end

end
