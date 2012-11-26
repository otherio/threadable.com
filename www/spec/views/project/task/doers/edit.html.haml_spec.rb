require 'spec_helper'

describe "project/tasks/edit" do
  before(:each) do
    @project_task = assign(:project_task, stub_model(Project::Task::Doer))
  end

  it "renders the edit project_task form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => project_task_doers_path(@project_task), :method => "post" do
    end
  end
end
