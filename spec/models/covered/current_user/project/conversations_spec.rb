require 'spec_helper'

describe Covered::CurrentUser::Project::Conversations do

  let(:covered_current_user_record){ Factories.create(:user) }
  let(:project_record){ Factories.create(:project) }
  before{ project_record.members << covered_current_user_record }
  let(:project){ Covered::CurrentUser::Project.new(current_user, project_record) }
  let(:conversations){ project.conversations }
  subject{ conversations }

  its(:covered){ should eq covered }
  its(:project){ should eq project }
  its(:inspect){ should eq %(#<Covered::CurrentUser::Project::Conversations project_id: #{project.id.inspect}>) }


  its(:build){ should be_a Covered::CurrentUser::Project::Conversation }
  its(:new  ){ should be_a Covered::CurrentUser::Project::Conversation }

  context 'build(type:"Task")' do
    subject{ conversations.build(type:"Task") }
    it{ should be_a Covered::CurrentUser::Project::Task }
    its(:project){ should eq project }
  end

  its(:all){ should eq [] }
  context "when there are conversations" do
    before do
      @conversation_records = 2.times.map{
        conversation_record = Factories.create(:conversation, project: project_record)
        Covered::CurrentUser::Project::Conversation.new(project, conversation_record)
      }
    end
    its(:all){ should =~ @conversation_records }

    describe "find_by_slug" do
      subject{ conversations.find_by_slug(@conversation_records.first.slug) }
      it{ should eq @conversation_records.first }
    end
  end
end
