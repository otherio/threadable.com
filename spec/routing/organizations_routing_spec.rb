require "spec_helper"

describe OrganizationsController do
  describe "routing" do

    it "routes to #new" do
      get("/organizations/new").should route_to("organizations#new")
    end

    it "routes to #show" do
      get("/1").should route_to("organizations#show", :id => "1")
    end

    it "routes to #edit" do
      get("/1/edit").should route_to("organizations#edit", :id => "1")
    end

    it "routes to #create" do
      post("/organizations").should route_to("organizations#create")
    end

    it "routes to #update" do
      put("/1").should route_to("organizations#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/organizations/1").should route_to("organizations#destroy", :id => "1")
    end

    it "routes to #user_list" do
      get("/1/user_list").should route_to("organizations#user_list", :id => "1")
    end

  end
end
