require 'spec_helper'

describe "project/tasks/show" do
  before(:each) do
    @project_task = assign(:project_task, stub_model(Project::Task::Doer))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
