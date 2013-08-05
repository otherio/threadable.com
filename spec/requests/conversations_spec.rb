require 'spec_helper'

describe "Conversations" do
  describe "GET /conversations" do

    let!(:current_user){ User.where(name: 'Alice Neilson').first! }
    let!(:project){ current_user.projects.first! }

    before do
      login_as current_user
    end

    it "displays tasks as tasks" do
      task = create(:task, project: project)

      visit project_conversation_path(project, task)

      expect(page).to have_content 'doers:'
      expect(page).to have_content 'mark as done'
    end

  end
end
