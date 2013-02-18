require "spec_helper"

describe Task::DoersController do
  describe "routing" do

    it "routes to #create" do
      post("/love-a-duck/tasks/w-the-f/doers").should route_to("task/doers#create", :project_id => 'love-a-duck', :task_id => 'w-the-f')
    end

    it "routes to #destroy" do
      pending
    end

  end
end
