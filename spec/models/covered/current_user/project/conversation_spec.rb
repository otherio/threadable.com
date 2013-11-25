require 'spec_helper'

describe Covered::CurrentUser::Project::Conversation do

  let(:covered_current_user_record){ Factories.create(:user) }
  let(:conversation_record){ Factories.create(:conversation) }
  let(:project_record){ conversation_record.project }
  before{ project_record.members << covered_current_user_record }

  let(:project){ Covered::CurrentUser::Project.new(current_user, project_record) }
  let(:conversation){ Covered::CurrentUser::Project::Conversation.new(project, conversation_record) }

  subject{ conversation }

  its(:covered     ){ should eq covered                         }
  its(:project     ){ should eq project                         }
  its(:id          ){ should eq conversation_record.id          }
  its(:to_param    ){ should eq conversation_record.to_param    }
  its(:slug        ){ should eq conversation_record.slug        }
  its(:subject     ){ should eq conversation_record.subject     }
  its(:task?       ){ should eq conversation_record.task?       }
  its(:created_at  ){ should eq conversation_record.created_at  }
  its(:updated_at  ){ should eq conversation_record.updated_at  }
  its(:persisted?  ){ should eq conversation_record.persisted?  }
  its(:new_record? ){ should eq conversation_record.new_record? }
  its(:errors      ){ should eq conversation_record.errors      }

  its(:creator     ){ should be_a Covered::CurrentUser::Project::Conversation::Creator      }
  its(:events      ){ should be_a Covered::CurrentUser::Project::Conversation::Events       }
  its(:messages    ){ should be_a Covered::CurrentUser::Project::Conversation::Messages     }
  its(:recipients  ){ should be_a Covered::CurrentUser::Project::Conversation::Recipients   }
  its(:participants){ should be_a Covered::CurrentUser::Project::Conversation::Participants }

  describe '#update' do
    it "should update the user record" do
      expect(conversation.update(subject: 'buy some shoes')).to be_true
      conversation_record.reload
      expect(conversation_record.subject).to eq 'buy some shoes'
    end
  end

end
