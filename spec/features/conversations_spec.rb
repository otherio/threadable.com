require 'spec_helper'

feature "Conversations" do

  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }

  before do
    sign_in_as 'bethany@ucsd.example.com'
  end

  scenario "viewing conversations" do

    visit organization_conversations_path(organization)

    muted_conversations = organization.conversations.muted_with_participants
    not_muted_conversations = organization.conversations.not_muted_with_participants

    within '.conversation_list' do
      not_muted_conversations.each do |conversation|
        expect(page).to have_link conversation.subject
      end

      muted_conversations.each do |conversation|
        expect(page).to_not have_link conversation.subject
      end
    end

    click_on 'Muted'

    within '.conversation_list' do
      not_muted_conversations.each do |conversation|
        expect(page).to_not have_link conversation.subject
      end

      muted_conversations.each do |conversation|
        expect(page).to have_link conversation.subject
      end
    end

    click_on 'Not Muted'

    within '.conversation_list' do
      not_muted_conversations.each do |conversation|
        expect(page).to have_link conversation.subject
      end

      muted_conversations.each do |conversation|
        expect(page).to_not have_link conversation.subject
      end
    end

  end

  context "viewing a conversation" do
    before{ visit organization_conversation_path(organization, conversation) }

    context "when the conversation is a task" do
      let(:conversation){ organization.tasks.find_by_slug! 'install-mirrors' }

      scenario "displays tasks as tasks" do
        expect(page).to have_content 'doers:'
        expect(page).to have_content 'sign me up'
        expect(page).to have_content 'add/remove others'
        expect(page).to have_content 'mark as done'
        expect(page).to have_content 'mute conversation'
      end
    end

    context "when the conversation is not a task" do
      let(:conversation){ organization.conversations.find_by_slug! 'how-are-we-going-to-build-the-body' }

      scenario "displays as conversation" do
        expect(page).to_not have_content 'doers:'
        expect(page).to_not have_content 'sign me up'
        expect(page).to_not have_content 'add/remove others'
        expect(page).to_not have_content 'mark as done'
        expect(page).to have_content 'mute conversation'
      end
    end

  end
end
