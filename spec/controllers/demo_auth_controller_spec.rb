require 'spec_helper'

describe DemoAuthController do

  let(:alice){ User.with_email('amywong.phd@gmail.com').first! }

  describe "GET index" do
    it "should redirect to the project conversations page" do
      get :index
      expect(assigns[:current_user]).to eq alice
      expect(response).to redirect_to project_conversations_path(alice.projects.first)
    end
  end
end

