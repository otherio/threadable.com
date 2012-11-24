require 'spec_helper'

describe "Tasks" do
  describe "GET /tasks" do
    let!(:project){  Project.create! :name => 'love someone' }
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get project_tasks_path(project)
      response.status.should be(200)
    end
  end
end
