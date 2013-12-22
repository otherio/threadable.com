require "spec_helper"

describe ConversationsController do
  describe "routing" do

    it "routes to #index" do
      get("/love-a-duck/conversations").should route_to("conversations#index", :organization_id => 'love-a-duck')
    end

    it "routes to #show" do
      get("/love-a-duck/conversations/we-need-more-lube").should route_to("conversations#show", :id => "we-need-more-lube", :organization_id => 'love-a-duck')
    end

    it "routes to #create" do
      post("/love-a-duck/conversations").should route_to("conversations#create", :organization_id => 'love-a-duck')
    end

    # it "routes to #mute" do
    #   put("/love-a-duck/conversations/we-need-more-lube/mute").should route_to("conversations#mute", :id => "we-need-more-lube", :organization_id => 'love-a-duck')
    # end

  end
end
