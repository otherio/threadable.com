require "spec_helper"

describe Admin::OrganizationsController do
  describe "routing" do

    it "routes to #index" do
      expect( get("/admin/organizations") ).to route_to("admin/organizations#index")
    end

    it "routes to #new" do
      expect( get("/admin/organizations/new") ).to route_to("admin/organizations#new")
    end

    it "routes to #show" do
      expect( get("/admin/organizations/1") ).to_not route_to("admin/organizations#show", :id => "1")
    end

    it "routes to #edit" do
      expect( get("/admin/organizations/1/edit") ).to route_to("admin/organizations#edit", :id => "1")
    end

    it "routes to #create" do
      expect( post("/admin/organizations") ).to route_to("admin/organizations#create")
    end

    it "routes to #update" do
      expect( patch("/admin/organizations/1") ).to route_to("admin/organizations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect( delete("/admin/organizations/1") ).to route_to("admin/organizations#destroy", :id => "1")
    end

  end
end
