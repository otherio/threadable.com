require 'spec_helper'

describe DemoAuthController do

  let(:amy){ Covered::User.with_email('amywong.phd@gmail.com').first! }

  describe "GET index" do
    it "should redirect to the project conversations page" do
      get :index
      expect(controller.current_user).to eq amy
      expect(response).to redirect_to project_conversations_path(amy.projects.first)
    end
  end
end

