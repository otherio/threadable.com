require 'spec_helper'

describe DemoAuthController do

  let(:alice){ User.where(name: "Alice Neilson").first! }

  describe "GET index" do
    it "should redirect to the project conversations page" do
      get :index
      response.should redirect_to project_conversations_path(alice.projects.first)
    end
  end
end

