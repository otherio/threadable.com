require 'spec_helper'

describe DemoAuthController do

  let(:amy){ find_user_by_email_address('amywong.phd@gmail.com') }
  let(:project){ current_user.projects.find_by_slug!('sfhealth') }

  describe "GET index" do
    it "should redirect to the project conversations page" do
      get :index
      expect(controller.current_user.id).to eq amy.id
      expect(response).to redirect_to project_conversations_path(project)
    end
  end
end

