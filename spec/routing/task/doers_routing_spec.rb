require "spec_helper"

describe Task::DoersController do
  describe "routing" do

    it "routes to #create" do
      post("/love-a-duck/tasks/w-the-f/doers").should route_to("task/doers#create", :project_id => 'love-a-duck', :task_id => 'w-the-f')
    end

    it "routes to #destroy" do
      delete("/love-a-duck/tasks/w-the-f/doers/1").should route_to("task/doers#destroy", :project_id => 'love-a-duck', :task_id => 'w-the-f', :id => '1')
    end

  end
end
