require 'spec_helper'

describe TaskMetadataWidget do

  let(:project_members) { double(:project_members, all: double(:all_project_members, to_json:'[project_members]')) }
  let(:task_doers) { double(:task_doers, all: double(:all_task_doers, to_json:'[task_doers]')) }
  let(:project) { double(:project, members: project_members) }
  let(:task) { double(:task, project: project, doers: task_doers) }
  let(:user) { double(:user) }
  let(:user_is_a_doer){ false }

  before do
    task_doers.stub(:include?).with(user).and_return(user_is_a_doer)
  end

  def html_options
    {
      class: 'custom_class',
      task: task,
      user: user,
    }
  end

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        task: task,
        user: user,
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "task_metadata custom_class",
        widget: "task_metadata",
        :'data-doers' => '[task_doers]',
        :'data-project_members' => '[project_members]',
      }
    end
  end

  context "when the given user is a doer" do
    let(:user_is_a_doer){ true }
    it "should add im-a-doer as a classname" do
      presenter.html_options[:class].should include 'im-a-doer'
    end
  end

end
