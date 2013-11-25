require 'spec_helper'

describe Covered::CurrentUser::Project::Tasks do

  let(:covered_current_user_record){ Factories.create(:user) }
  let(:project_record){ Factories.create(:project) }
  before{ project_record.members << covered_current_user_record }
  let(:project){ Covered::CurrentUser::Project.new(current_user, project_record) }
  let(:tasks){ project.tasks }
  subject{ tasks }

  its(:covered){ should eq covered }
  its(:project){ should eq project }
  its(:inspect){ should eq %(#<Covered::CurrentUser::Project::Tasks project_id: #{project.id.inspect}>) }


  its(:build){ should be_a Covered::CurrentUser::Project::Task }
  its(:new  ){ should be_a Covered::CurrentUser::Project::Task }

  context 'build(type:"Task")' do
    subject{ tasks.build(type:"Task") }
    it{ should be_a Covered::CurrentUser::Project::Task }
    its(:project){ should eq project }
  end

  its(:all){ should eq [] }
  context "when there are tasks" do
    before do
      @task_records = 2.times.map{
        task_record = Factories.create(:task, project: project_record)
        Covered::CurrentUser::Project::Task.new(project, task_record)
      }
    end
    its(:all){ should =~ @task_records }

    describe "find_by_slug" do
      subject{ tasks.find_by_slug(@task_records.first.slug) }
      it{ should eq @task_records.first }
    end
  end

end
