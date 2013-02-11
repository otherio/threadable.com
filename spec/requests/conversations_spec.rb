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

    it "displays tasks as tasks" do
      task = create(:task, project: project)

      get project_conversation_path({project_id: project.to_param, id: task.to_param})
      response.should be_success

      response.body.should =~ /icon-ok/
      response.body.should =~ /doers:/
      response.body.should =~ /mark as done/
    end


  end
end
