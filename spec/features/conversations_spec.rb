require 'spec_helper'

describe "Conversations" do
  describe "GET /conversations" do

    before{ sign_in_as 'alice@ucsd.example.com' }

    let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }

    before do
      visit organization_conversation_path(organization, conversation)
    end

    context "when the conversation is a task" do
      let(:conversation){ organization.tasks.find_by_slug! 'install-mirrors' }

      it "displays tasks as tasks" do
        visit organization_conversation_path(organization, conversation)
        expect(page).to have_content 'doers:'
        expect(page).to have_content 'mark as done'
      end
    end

    context "when the conversation is a task" do
      let(:conversation){ organization.conversations.find_by_slug! 'how-are-we-going-to-build-the-body' }

      it "displays tasks as tasks" do
        expect(page).to_not have_content 'doers:'
        expect(page).to_not have_content 'mark as done'
      end
    end

  end
end
