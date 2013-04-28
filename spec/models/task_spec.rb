require 'spec_helper'

describe Task do
  it { should belong_to(:project) }
  it { should have_many(:messages) }
  it { should have_and_belong_to_many(:doers) }

  # mass assignment
  [:due_at, :done_at].each do |field|
    it { should allow_mass_assignment_of(field) }
  end

  describe "#task?" do
    it "should return true" do
      Task.new.should be_task
    end
  end

  describe "#done?" do
    it "should return true if done_at is present" do
      Task.new(done_at: Time.now).should be_done
      Task.new(done_at: nil).should_not be_done
      Task.new.should_not be_done
    end
  end

  describe "#done!" do
    let(:task){ create(:task) }
    it "should set done_at to Time.now and save!" do
      time = Time.at(2132132131)
      Time.stub(:now).and_return(time)

      task.done_at.should be_nil
      task.should_not be_done
      Task::DoneEvent.should_receive(:create!)
      task.done! User.new
      task.should be_done
      task.done_at.should == time
      Task::UndoneEvent.should_receive(:create!)
      task.undone! User.new
      task.done_at.should be_nil
      task.should_not be_done
    end

    it 'is idempotent' do
      Task::DoneEvent.should_receive(:create!).once
      user = User.new

      Time.stub(:now).and_return(Time.at(2132132131))
      task.done! user

      Time.stub(:now).and_return(Time.at(2132132133))
      task.done! user

      Task.any_instance.should_receive(:save!).once

      Time.stub(:now).and_return(Time.at(2132132135))
      task.undone! user

      Time.stub(:now).and_return(Time.at(2132132137))
      task.undone! user
    end
  end

end
