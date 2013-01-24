require "spec_helper"

describe ProjectsController do
  describe "routing" do

    it "routes to #index" do
      get("/projects").should route_to("projects#index")
    end

    it "routes to #new" do
      get("/projects/new").should route_to("projects#new")
    end

    it "routes to #show" do
      get("/ddi").should route_to("projects#show", :id => "ddi")
    end

    it "routes to #edit" do
      get("/projects/ddi/edit").should route_to("projects#edit", :id => "ddi")
    end

    it "routes to #create" do
      post("/projects").should route_to("projects#create")
    end

    it "routes to #update" do
      put("/projects/ddi").should route_to("projects#update", :id => "ddi")
    end

    it "routes to #destroy" do
      delete("/projects/ddi").should route_to("projects#destroy", :id => "ddi")
    end

  end
end
