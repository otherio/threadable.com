require 'spec_helper'

describe "Conversations" do
  describe "GET /conversations" do

    before{ sign_in_as 'alice@ucsd.covered.io' }

    let(:project){ current_user.projects.find_by_slug! 'raceteam' }

    before do
      visit project_conversation_path(project, conversation)
    end

    context "when the conversation is a task" do
      let(:conversation){ project.tasks.find_by_slug! 'install-mirrors' }

      it "displays tasks as tasks" do
        visit project_conversation_path(project, conversation)
        expect(page).to have_content 'doers:'
        expect(page).to have_content 'mark as done'
      end
    end

    context "when the conversation is a task" do
      let(:conversation){ project.conversations.find_by_slug! 'how-are-we-going-to-build-the-body' }

      it "displays tasks as tasks" do
        expect(page).to_not have_content 'doers:'
        expect(page).to_not have_content 'mark as done'
      end
    end

  end
end
