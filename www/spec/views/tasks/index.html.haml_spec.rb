require 'spec_helper'

describe "tasks/index" do
  before(:each) do
    project = assign(:project, Project.create!(:name => "Name"))
    assign(:tasks, [
      Task.create!(
        :name => "Name",
        :done => false,
        :project => project,
      ),
      Task.create!(
        :name => "Name",
        :done => false,
        :project => project,
      )
    ])
  end

  it "renders a list of tasks" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
