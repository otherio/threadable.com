require 'spec_helper'

describe Covered::CurrentUser::Project::Task do

  let(:covered_current_user_record){ Factories.create(:user) }
  let(:task_record){ Factories.create(:task) }
  let(:project_record){ task_record.project }
  before{ project_record.members << covered_current_user_record }

  let(:project){ Covered::CurrentUser::Project.new(current_user, project_record) }
  let(:task){ Covered::CurrentUser::Project::Task.new(project, task_record) }

  subject{ task }

  its(:covered     ){ should eq covered                 }
  its(:project     ){ should eq project                 }
  its(:id          ){ should eq task_record.id          }
  its(:to_param    ){ should eq task_record.to_param    }
  its(:slug        ){ should eq task_record.slug        }
  its(:subject     ){ should eq task_record.subject     }
  its(:task?       ){ should eq task_record.task?       }
  its(:created_at  ){ should eq task_record.created_at  }
  its(:updated_at  ){ should eq task_record.updated_at  }
  its(:persisted?  ){ should eq task_record.persisted?  }
  its(:new_record? ){ should eq task_record.new_record? }
  its(:errors      ){ should eq task_record.errors      }
  its(:done?       ){ should eq task_record.done?       }
  its(:position    ){ should eq task_record.position    }

  its(:creator     ){ should be_a Covered::CurrentUser::Project::Conversation::Creator      }
  its(:events      ){ should be_a Covered::CurrentUser::Project::Conversation::Events       }
  its(:messages    ){ should be_a Covered::CurrentUser::Project::Conversation::Messages     }
  its(:recipients  ){ should be_a Covered::CurrentUser::Project::Conversation::Recipients   }
  its(:participants){ should be_a Covered::CurrentUser::Project::Conversation::Participants }
  its(:doers       ){ should be_a Covered::CurrentUser::Project::Task::Doers                }

  describe '#update' do
    it "should update the user record" do
      expect(task.update(subject: 'buy some shoes')).to be_true
      task_record.reload
      expect(task_record.subject).to eq 'buy some shoes'
    end
  end

  describe 'done!' do
    it 'should mark the task as done and create a Task::DoneEvent' do
      expect(task).to_not be_done
      expect{ task.done! }.to change{ Task::DoneEvent.count }.by(1)
      expect(task).to be_done
      event = Task::DoneEvent.last!
      expect(event.task_id).to eq task.id
      expect(event.user_id).to eq current_user.id
    end
  end

  describe 'undone!' do
    before{ task.done! }
    it 'should mark the task as not done and create a Task::UndoneEvent' do
      expect(task).to be_done
      expect{ task.undone! }.to change{ Task::UndoneEvent.count }.by(1)
      expect(task).to_not be_done
      event = Task::UndoneEvent.last!
      expect(event.task_id).to eq task.id
      expect(event.user_id).to eq current_user.id
    end
  end

end
