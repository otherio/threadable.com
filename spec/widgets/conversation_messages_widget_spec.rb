require 'spec_helper'

describe ConversationMessagesWidget do

  def generate_created_at
    @created_at ||= 1000.seconds.ago
    @created_at += 10
  end

  let :events do
    [
      double(:event0, created_at: 9.minutes.ago),
      double(:event1, created_at: 7.minutes.ago),
      double(:event2, created_at: 5.minutes.ago),
      double(:event3, created_at: 3.minutes.ago),
    ]
  end

  let :messages do
    [
      double(:message0, created_at: 8.minutes.ago),
      double(:message1, created_at: 6.minutes.ago),
      double(:message2, created_at: 4.minutes.ago),
      double(:message3, created_at: 2.minutes.ago),
    ]
  end

  let :items do
    [
      [:event, events[0]], [:message, messages[0]],
      [:event, events[1]], [:message, messages[1]],
      [:event, events[2]], [:message, messages[2]],
      [:event, events[3]], [:message, messages[3]],
    ]
  end

  let(:conversation) { double(:conversation, messages: messages, events: events) }
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
        items: items,
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
          items: items,
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
