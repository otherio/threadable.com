require 'spec_helper'

describe "events" do

  let(:project){ create(:project) }

  it "should create events when things happen" do

    expected_event_types = []

    5.times{ project.members << create(:user) }
    #
    project.conversations.create! subject: 'Welcome Everyone', creator: project.members.first

    expected_event_types << "Covered::Conversation::CreatedEvent"
    project.events.reload
    project.events.map(&:type).should == expected_event_types
    project.events.last.class.should == Covered::Conversation::CreatedEvent
    project.events.last.conversation.should == project.conversations.first

    #
    project.tasks.create! subject: 'buy some cereal', creator: project.members.second

    expected_event_types << "Covered::Task::CreatedEvent"
    project.events.reload
    project.events.map(&:type).should == expected_event_types
    project.events.last.class.should == Covered::Task::CreatedEvent
    project.events.last.conversation.should == project.tasks.last

    # task done event
    project.tasks.last.done! project.members.first
    project.tasks.last.done! project.members.first # idempotent

    expected_event_types << "Covered::Task::DoneEvent"
    project.events.reload
    project.events.map(&:type).should == expected_event_types
    project.events.last.class.should == Covered::Task::DoneEvent
    project.events.last.conversation.should == project.tasks.last

    #
    project.tasks.last.undone! project.members.first
    project.tasks.last.undone! project.members.first # idempotent

    expected_event_types << "Covered::Task::UndoneEvent"

    project.events.reload
    project.events.map(&:type).should == expected_event_types
    project.events.last.class.should == Covered::Task::UndoneEvent
    project.events.last.conversation.should == project.tasks.last


    # task done event
    project.tasks.last.done! project.members.first

    expected_event_types << "Covered::Task::DoneEvent"
    project.events.reload
    project.events.map(&:type).should == expected_event_types
    project.events.last.class.should == Covered::Task::DoneEvent
    project.events.last.conversation.should == project.tasks.last

  end

end
