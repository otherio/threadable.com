require 'spec_helper'

describe DemoAuthController do

  let(:alice){ User.find_by_name("Alice Neilson")}

  describe "GET index" do
    it "should redirect to the project conversations page" do
      get :index
      response.should redirect_to project_conversations_path(alice.projects.first)
    end
  end
end

