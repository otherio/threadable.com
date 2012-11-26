require 'spec_helper'

describe "project/tasks/new" do
  before(:each) do
    assign(:project_task, stub_model(Project::Task::Doer).as_new_record)
  end

  it "renders new project_task form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => project_task_doers_path, :method => "post" do
    end
  end
end
