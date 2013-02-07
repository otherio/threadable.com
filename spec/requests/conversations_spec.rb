require 'spec_helper'

describe "Conversations" do
  describe "GET /conversations" do

    let!(:current_user){ create(:user) }
    let!(:project){ create(:project) }

    before do
      project.members << current_user
      post(new_user_session_path,
        user: {
          email: current_user.email,
          password: 'password',
          remember_me: 0,
        },
        commit: 'Sign in',
      )
      response.should be_redirect
    end

    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get project_conversations_path(project)
      response.status.should be(200)
    end
  end
end
