require "spec_helper"

describe ConversationsController do
  describe "routing" do

    it "routes to #index" do
      get("/love-a-duck/conversations").should route_to("conversations#index", :project_id => 'love-a-duck')
    end

    it "routes to #show" do
      get("/love-a-duck/conversations/we-need-more-lube").should route_to("conversations#show", :id => "we-need-more-lube", :project_id => 'love-a-duck')
    end

    it "routes to #create" do
      post("/love-a-duck/conversations").should route_to("conversations#create", :project_id => 'love-a-duck')
    end

    it "routes to #mute" do
      put("/love-a-duck/conversations/we-need-more-lube/mute").should route_to("conversations#mute", :id => "we-need-more-lube", :project_id => 'love-a-duck')
    end

    it "routes to #add_doer" do
      post("/love-a-duck/conversations/we-need-more-lube/add_doer").should route_to("conversations#add_doer", :task_id => "we-need-more-lube", :project_id => 'love-a-duck')
    end

  end
end
