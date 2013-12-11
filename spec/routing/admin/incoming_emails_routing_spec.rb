require "spec_helper"

describe Admin::IncomingEmailsController do
  describe "routing" do

    it "routes to #index" do
      expect( get("/admin/incoming_emails") ).to route_to("admin/incoming_emails#index")
    end

    it "routes to #show" do
      expect( get("/admin/incoming_emails/1") ).to route_to("admin/incoming_emails#show", :id => "1")
    end

  end
end
