require 'spec_helper'

describe "tasks/show" do
  before(:each) do

    assign(:task, Task.create!(
      :name => "Name",
      :done => false,
      :project => Project.create!(:name => "Name"),
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/false/)
  end
end
