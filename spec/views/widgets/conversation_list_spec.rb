require 'spec_helper'

describe "conversation_list" do

  let(:participants){
    10.times.map{|i| double(:"user#{i}",  name: "user#{i}") }
  }

  let(:creator) { double(:creator,  name: "creator") }

  def participant_names *indices
    indices.empty? ? [] : participants[*indices].map(&:name)
  end

  let(:conversations){
    [
      double(:conversation1, id: 1, to_param: 'conversation-one',   subject: 'conversation one',   participant_names: participant_names(0,3), updated_at: 1.hour.ago),
      double(:conversation2, id: 2, to_param: 'conversation-two',   subject: 'conversation two',   participant_names: participant_names(3,2), updated_at: 2.months.ago),
      double(:conversation3, id: 3, to_param: 'conversation-three', subject: 'conversation three', participant_names: participant_names(5,1), updated_at: 13.months.ago),
      double(:conversation4, id: 4, to_param: 'conversation-four',  subject: 'conversation four',  participant_names: ['Larry'],              updated_at: 15.months.ago, creator: creator),
    ]
  }
  let(:organization){ double(:organization, to_param: 'some-organization', held_messages: double(:held_messages, count: 0)) }

  def locals
    {
      organization: organization,
      conversations: conversations
    }
  end

  before do
    conversations.each_with_index do |conversation, index|
      conversation.stub('messages_count' => index + 10)
    end
  end

  it "should render a list of the given converations" do
    conversation_elements = html.css('.conversation')
    conversation_elements.size.should == 4

    conversation_elements[0].css('td.participants').first.text.should == "\n\nuser0\nuser1\nuser2\n\n(10)\n"
    conversation_elements[0].css('a').first[:href].should == "/some-organization/conversations/conversation-one"
    conversation_elements[0].css('.datetime').first.text.strip.should == conversations[0].updated_at.strftime('%l:%M %p').strip

    conversation_elements[1].css('td.participants').first.text.should == "\n\nuser3\nuser4\n\n(11)\n"
    conversation_elements[1].css('a').first[:href].should == "/some-organization/conversations/conversation-two"
    conversation_elements[1].css('.datetime').first.text.strip.should == conversations[1].updated_at.strftime('%b %-d').strip

    conversation_elements[2].css('td.participants').first.text.should == "\n\nuser5\n\n(12)\n"
    conversation_elements[2].css('a').first[:href].should == "/some-organization/conversations/conversation-three"
    conversation_elements[2].css('.datetime').first.text.strip.should == conversations[2].updated_at.strftime('%-m/%-d/%Y').strip

    conversation_elements[3].css('td.participants').first.text.should == "\n\nLarry\n\n(13)\n"
    conversation_elements[3].css('a').first[:href].should == "/some-organization/conversations/conversation-four"
    conversation_elements[3].css('.datetime').first.text.strip.should == conversations[3].updated_at.strftime('%-m/%-d/%Y').strip
  end

end
