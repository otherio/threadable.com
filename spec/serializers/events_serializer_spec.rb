require 'spec_helper'

describe EventsSerializer do

  let(:raceteam)      { threadable.organizations.find_by_slug!('raceteam') }
  let(:sfhealth)      { threadable.organizations.find_by_slug!('sfhealth') }
  let(:conversation)  { raceteam.conversations.find_by_slug!('get-a-new-soldering-iron') }
  let(:user)          { raceteam.members.find_by_email_address('alice@ucsd.example.com') }
  let(:message_event) { conversation.events.with_messages(user).find { |e| e.event_type == :created_message} }
  let(:message)       { message_event.message }
  let(:event)         { conversation.events.with_messages(user).find { |e| e.event_type == :task_added_doer} }
  let(:group_event)   { conversation.events.with_messages(user).find { |e| e.event_type == :conversation_added_group} }

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  context 'when given a single message record' do
    let(:payload){ message_event }
    let(:expected_key){ :event }
    it do
      should eq(
        id:         message_event.id,
        event_type: :created_message,
        actor:      message.creator.name,
        doer:       nil,
        group:      nil,
        created_at: message.date_header,
        message:    serialize(:messages, message).values.first,
      )
    end
  end

  context 'when given a single event record' do
    let(:payload){ event }
    let(:expected_key){ :event }
    it do
      should eq(
        id:         event.id,
        event_type: :task_added_doer,
        actor:      event.actor.name,
        doer:       event.doer.name,
        group:      nil,
        created_at: event.created_at,
        message:    nil,
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [message_event, event, group_event] }
    let(:expected_key){ :events }
    it do
      should eq [
        {
          id:         message_event.id,
          event_type: :created_message,
          actor:      message.creator.name,
          doer:       nil,
          group:      nil,
          created_at: message.date_header,
          message:    serialize(:messages, message).values.first,
        },{
          id:         event.id,
          event_type: :task_added_doer,
          actor:      event.actor.name,
          doer:       event.doer.name,
          group:      nil,
          created_at: event.created_at,
          message:    nil,
        },{
          id:         group_event.id,
          event_type: :conversation_added_group,
          actor:      group_event.actor.name,
          doer:       nil,
          group:      group_event.group.name,
          created_at: group_event.created_at,
          message:    nil,
        }
      ]
    end
  end

end
