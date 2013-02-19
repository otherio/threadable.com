require 'spec_helper'

describe "events" do

  let(:project){ create(:project) }

  it "should create events when things happen" do

    5.times{ project.members << create(:user) }

    #
    project.conversations.create! subject: 'Welcome Everyone', creator: project.members.first

    project.events.reload
    project.events.size.should == 1
    project.events.last.class.should == Conversation::CreatedEvent
    project.events.last.conversation.should == project.conversations.first

    #
    project.tasks.create! subject: 'buy some cereal', creator: project.members.second

    project.events.reload
    project.events.size.should == 2
    project.events.last.class.should == Task::CreatedEvent
    project.events.last.conversation.should == project.tasks.last

    # task done event
    project.tasks.last.done!
    project.tasks.last.done! # idempotent

    project.events.reload
    project.events.size.should == 3
    project.events.last.class.should == Task::DoneEvent
    project.events.last.conversation.should == project.tasks.last

    #
    project.tasks.last.undone!
    project.tasks.last.undone! # idempotent

    project.events.reload
    project.events.size.should == 4
    project.events.last.class.should == Task::UndoneEvent
    project.events.last.conversation.should == project.tasks.last


    # task done event
    project.tasks.last.done!

    project.events.reload
    project.events.size.should == 5
    project.events.last.class.should == Task::DoneEvent
    project.events.last.conversation.should == project.tasks.last

  end

end
