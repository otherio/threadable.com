require "spec_helper"

describe ProjectsController do
  describe "routing" do

    it "routes to #new" do
      get("/new").should route_to("projects#new")
    end

    it "routes to #show" do
      get("/1").should route_to("projects#show", :id => "1")
    end

    it "routes to #edit" do
      get("/1/edit").should route_to("projects#edit", :id => "1")
    end

    it "routes to #create" do
      post("/").should route_to("projects#create")
    end

    it "routes to #update" do
      put("/1").should route_to("projects#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/1").should route_to("projects#destroy", :id => "1")
    end

  end
end
