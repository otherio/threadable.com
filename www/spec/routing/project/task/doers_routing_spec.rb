require "spec_helper"

describe Project::Task::DoersController do
  describe "routing" do

    it "routes to #index" do
      get("/project/tasks").should route_to("project/tasks#index")
    end

    it "routes to #new" do
      get("/project/tasks/new").should route_to("project/tasks#new")
    end

    it "routes to #show" do
      get("/project/tasks/1").should route_to("project/tasks#show", :id => "1")
    end

    it "routes to #edit" do
      get("/project/tasks/1/edit").should route_to("project/tasks#edit", :id => "1")
    end

    it "routes to #create" do
      post("/project/tasks").should route_to("project/tasks#create")
    end

    it "routes to #update" do
      put("/project/tasks/1").should route_to("project/tasks#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/project/tasks/1").should route_to("project/tasks#destroy", :id => "1")
    end

  end
end
