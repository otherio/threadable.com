require "spec_helper"

describe Task::DoersController do
  describe "routing" do

    it "routes to #add" do
      post("/love-a-duck/tasks/w-the-f/doers").should route_to("task/doers#add", :organization_id => 'love-a-duck', :task_id => 'w-the-f')
    end

    it "routes to #remove" do
      delete("/love-a-duck/tasks/w-the-f/doers/1").should route_to("task/doers#remove", :organization_id => 'love-a-duck', :task_id => 'w-the-f', :user_id => '1')
    end

  end
end
