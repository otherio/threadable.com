require "spec_helper"

describe UsersController do
  describe "routing" do

    it "routes to #index" do
      get("/api/users").should route_to("users#index")
    end

    it "routes to #show" do
      get("/api/users/1").should route_to("users#show", :id => "1")
    end

    pending "routes to #create" do
      # we'll need this eventually for invitations I think, but maybe not.
      post("/api/users").should route_to("users#create")
    end

    it "routes to #update" do
      put("/api/users/1").should route_to("users#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/api/users/1").should route_to("users#destroy", :id => "1")
    end
  end
end
