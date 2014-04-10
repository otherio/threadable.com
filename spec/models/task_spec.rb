require 'spec_helper'

describe Task do
  it { should belong_to(:organization) }
  it { should have_many(:messages) }
  it { should have_and_belong_to_many(:doers) }

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

  # describe "#done!" do

  #   let(:current_user){ task.doers.first! }
  #   let(:now){ Time.at(2132132131) }

  #   before{ Time.stub(:now).and_return(now) }

  #   context "when the task is done" do

  #     let(:task){ Task.with_doers.done.first! }

  #     it "should do nothing" do
  #       expect(task).to_not receive :transaction
  #       expect(task).to_not receive :update!
  #       expect(task).to_not receive :save!
  #       expect{
  #         task.done! current_user
  #       }.to_not change{ Event.count }
  #     end

  #   end

  #   context "when the task is not done" do

  #     let(:task){ Task.with_doers.not_done.first! }

  #     it "should update done_at => Time.now and create a Task::DoneEvent record" do
  #       expect{
  #         task.done! current_user
  #       }.to change{ Event.count }.by(1)


  #       expect(task).to be_done
  #       expect(task.done_at).to eq now

  #       event = Event.last

  #       expect(event).to be_a Task::DoneEvent
  #       expect(event.task).to eq task
  #       expect(event.user).to eq current_user
  #     end
  #   end

  # end

end
