require 'spec_helper'

describe "conversation_list" do

  let(:conversations){
    [
      double(:conversation1, id: 1, to_param: 'conversation-one', subject: 'conversation one'),
      double(:conversation2, id: 2, to_param: 'conversation-two', subject: 'conversation two'),
    ]
  }
  let(:project){ double(:project, to_param: 'some-project') }

  def locals
    {
      project: project,
      conversations: conversations,
    }
  end

  before do
    conversations.each_with_index do |conversation, index|
      conversation.stub_chain('messages.count').and_return(index)
    end
  end

  it "should render a list of the given converations" do
    links = html.css('ul.conversations > li > a')
    links.size.should == 2
    links.map(&:text).should == ["(0) conversation one\n", "(1) conversation two\n"]
    links.map{|l| l[:href] }.should == [
      "/some-project/conversations/conversation-one",
      "/some-project/conversations/conversation-two",
    ]
  end

end
