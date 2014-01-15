require 'spec_helper'

describe EventsSerializer do

  let(:raceteam)      { covered.organizations.find_by_slug!('raceteam') }
  let(:sfhealth)      { covered.organizations.find_by_slug!('sfhealth') }
  let(:conversation)  { raceteam.conversations.find_by_slug!('layup-body-carbon') }
  let(:message_event) { conversation.events.with_messages.find { |e| e.event_type == :created_message} }
  let(:message)       { message_event.message }
  let(:event)         { conversation.events.with_messages.find { |e| e.event_type == :task_added_doer} }

  context 'when given a single message record' do
    let(:payload){ message_event }
    let(:expected_key){ :event }
    it do
      should eq(
        id:         message_event.id,
        event_type: :created_message,
        actor:      message.creator.name,
        doer:       nil,
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
        created_at: event.created_at,
        message:    nil,
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [message_event, event] }
    let(:expected_key){ :events }
    it do
      should eq [
        {
          id:         message_event.id,
          event_type: :created_message,
          actor:      message.creator.name,
          doer:       nil,
          created_at: message.date_header,
          message:    serialize(:messages, message).values.first,
        },{
          id:         event.id,
          event_type: :task_added_doer,
          actor:      event.actor.name,
          doer:       event.doer.name,
          created_at: event.created_at,
          message:    nil,
        }
      ]
    end
  end

end
