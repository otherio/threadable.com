require "spec_helper"

describe RegistrationsController do
  describe "routing" do
    it "routes to #create" do
      post("/api/users/register").should route_to("registrations#create")
    end
  end
end
