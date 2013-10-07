require 'spec_helper'

describe "conversation_messages" do

  def generate_created_at
    @created_at ||= 1000.seconds.ago
    @created_at += 10
  end

  def create_event index, type
    double(:"event",
      index: index,
      type: type,
      created_at: generate_created_at,
      user: double(:user, name:"[event#{index} user name]"), )
  end

  def create_message index
    double(:"message", index: index, created_at: generate_created_at)
  end

  let :items do
    [
      [:event,   create_event(0, 'Conversation::CreatedEvent')],
      [:message, create_message(0)],
      [:event,   create_event(1, 'Task::CreatedEvent')],
      [:message, create_message(1)],
      [:event,   create_event(2, 'Task::DoneEvent')],
      [:message, create_message(2)],
      [:event,   create_event(3, 'Task::UndoneEvent')],
    ]
  end

  let(:conversation){ double(:conversation) }

  let(:from){ double(:from) }

  def locals
    {items: items, conversation: conversation, from: from}
  end

  before do
    items.each do |type, item|
      case type
      when :message
        view.should_receive(:render_widget).
          with(:message, item).
          and_return(%(<div class="message">message widget html for message#{item.index}</div>).html_safe)
      end
    end

    view.should_receive(:render_widget).
      with(:new_conversation_message, conversation, from: from).
      and_return('NEW CONVERSATION WIDGET')
  end

  it "should return a list of messages and a new conversation form at the bottom" do
    list_items = html.css('ol > li > *')

    list_items.map{|li| li[:class] }.should == %w(event message event message event message event)
    list_items.map(&:text).map(&:strip).should == [
      "[event0 user name] started this conversation",
      "message widget html for message0",
      "[event1 user name] created this task",
      "message widget html for message1",
      "[event2 user name] marked this task as done",
      "message widget html for message2",
      "[event3 user name] marked this task as not done",
    ]
    html.text.should include 'NEW CONVERSATION WIDGET'
  end

  describe "return value" do
    subject{ return_value }
    it { should be_a String}
  end

end
