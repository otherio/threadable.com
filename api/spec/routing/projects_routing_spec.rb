require "spec_helper"

describe ProjectsController do
  describe "routing" do

    it "routes to #index" do
      get("/api/projects").should route_to("projects#index")
    end

    it "routes to #new" do
      get("/api/projects/new").should route_to("projects#new")
    end

    it "routes to #show" do
      get("/api/projects/1").should route_to("projects#show", :id => "1")
    end

    it "routes to #edit" do
      get("/api/projects/1/edit").should route_to("projects#edit", :id => "1")
    end

    it "routes to #create" do
      post("/api/projects").should route_to("projects#create")
    end

    it "routes to #update" do
      put("/api/projects/1").should route_to("projects#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/api/projects/1").should route_to("projects#destroy", :id => "1")
    end

  end
end
