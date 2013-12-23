require 'spec_helper'

describe "conversation_list" do

  let(:creator) { double(:creator,  name: "creator") }

  let(:organization){ double(:organization, to_param: 'some-organization', held_messages: double(:held_messages, count: 0)) }

  def create_participant_names
    rand(2) == 0 ? [] : rand(4).times.map{ Faker::Name.first_name }
  end

  def create_conversation_double
    @conversation_double_count ||= 0
    id = @conversation_double_count += 1
    double(:"conversation#{id}",
      id:                id,
      to_param:          "conversation-#{id}",
      subject:           "conversation #{id}",
      participant_names: create_participant_names,
      creator:           double(:creator, name: "creator-of-conversation-#{id} smith"),
      updated_at:        id.hours.ago,
      messages_count:    rand(20),
    )
  end

  let(:not_muted_conversations){
    4.times.map{ create_conversation_double }
  }

  let(:muted_conversations){
    2.times.map{ create_conversation_double }
  }

  def locals
    {
      organization: organization,
      not_muted_conversations: not_muted_conversations,
      muted_conversations: muted_conversations,
    }
  end

  it "should render a list of the given converations" do
    not_muted_conversation_elements = html.css('.conversations.not_muted .conversation')
        muted_conversation_elements = html.css('.conversations.muted .conversation')

    not_muted_conversation_elements.size.should == 4
        muted_conversation_elements.size.should == 2

    (
      not_muted_conversations.zip(not_muted_conversation_elements) + muted_conversations.zip(muted_conversation_elements)
    ).map do |conversation, conversation_element|
      participant_names = conversation_element.css('td.participants .names span').map(&:text)
      expect(participant_names).to eq conversation.participant_names

      count = conversation_element.css('td.participants .count').first.text
      expect(count).to eq(conversation.messages_count > 1 ? "(#{conversation.messages_count})" : "")

      link = conversation_element.css('td.subject a').first
      expect(link.text).to eq conversation.subject
      expect(link[:href]).to eq "/some-organization/conversations/#{conversation.to_param}"

      datetime = conversation_element.css('.datetime').first.text.strip
      expect(datetime).to eq conversation.updated_at.strftime('%l:%M %p').strip
    end

  end

end
