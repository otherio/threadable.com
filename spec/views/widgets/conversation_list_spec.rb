require 'spec_helper'

describe "conversation_list" do

  let(:participants){
    10.times.map{|i| double(:"user#{i}",  name: "user#{i}") }
  }

  let(:creator) { double(:creator,  name: "creator") }

  let(:conversations){
    [
      double(:conversation1, id: 1, to_param: 'conversation-one',   subject: 'conversation one',   participants: participants[0,3], updated_at: 1.hour.ago),
      double(:conversation2, id: 2, to_param: 'conversation-two',   subject: 'conversation two',   participants: participants[3,2], updated_at: 2.months.ago),
      double(:conversation3, id: 3, to_param: 'conversation-three', subject: 'conversation three', participants: participants[5,1], updated_at: 13.months.ago),
      double(:conversation4, id: 4, to_param: 'conversation-four',  subject: 'conversation four',  participants: nil, updated_at: 15.months.ago, creator: creator),
    ]
  }
  let(:project){ double(:project, to_param: 'some-project') }

  def locals
    {
      project: project,
      conversations: conversations
    }
  end

  before do
    conversations.each_with_index do |conversation, index|
      conversation.stub_chain('messages.count').and_return(index + 10)
    end
  end

  it "should render a list of the given converations" do
    conversation_elements = html.css('.conversation')
    conversation_elements.size.should == 4

    conversation_elements[0].css('td.participants').first.text.should == "\n\nuser0\nuser1\nuser2\n\n(10)\n"
    conversation_elements[0].css('a').first[:href].should == "/some-project/conversations/conversation-one"
    conversation_elements[0].css('.datetime').first.text.strip.should == conversations[0].updated_at.strftime('%l:%M %p').strip

    conversation_elements[1].css('td.participants').first.text.should == "\n\nuser3\nuser4\n\n(11)\n"
    conversation_elements[1].css('a').first[:href].should == "/some-project/conversations/conversation-two"
    conversation_elements[1].css('.datetime').first.text.strip.should == conversations[1].updated_at.strftime('%b %-d').strip

    conversation_elements[2].css('td.participants').first.text.should == "\n\nuser5\n\n(12)\n"
    conversation_elements[2].css('a').first[:href].should == "/some-project/conversations/conversation-three"
    conversation_elements[2].css('.datetime').first.text.strip.should == conversations[2].updated_at.strftime('%-m/%-d/%Y').strip

    conversation_elements[3].css('td.participants').first.text.should == "\n\ncreator\n\n(13)\n"
    conversation_elements[3].css('a').first[:href].should == "/some-project/conversations/conversation-four"
    conversation_elements[3].css('.datetime').first.text.strip.should == conversations[3].updated_at.strftime('%-m/%-d/%Y').strip
  end

end
