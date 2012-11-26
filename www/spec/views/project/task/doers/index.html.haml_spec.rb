require 'spec_helper'

describe "project/tasks/index" do
  before(:each) do
    assign(:project_task_doers, [
      stub_model(Project::Task::Doer),
      stub_model(Project::Task::Doer)
    ])
  end

  it "renders a list of project/tasks" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
