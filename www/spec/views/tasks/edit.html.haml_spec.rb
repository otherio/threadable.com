require 'spec_helper'

describe "tasks/edit" do
  before(:each) do
    project = assign(:project, Project.create!(:name => "Name"))
    @task = assign(:task, Task.create!(
      :name => "MyString",
      :done => false,
      :project => project,
    ))
  end

  it "renders the edit task form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => project_tasks_path(@task.project), :method => "post" do
      assert_select "input#task_name", :name => "task[name]"
      assert_select "input#task_done", :name => "task[done]"
    end
  end
end
