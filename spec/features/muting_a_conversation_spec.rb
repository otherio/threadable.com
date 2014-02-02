# require 'spec_helper'

# feature "Muting a conversation" do

#   scenario %(muting and un-muting a conversation on the web) do
#     sign_in_as 'tom@ucsd.example.com'

#     conversation = threadable.conversations.find_by_slug!('layup-body-carbon')
#     expect(conversation.recipients.all).to include current_user
#     visit organization_conversation_url('raceteam', 'layup-body-carbon')
#     expect(page).to have_selector '.message'
#     click_on 'mute conversation'
#     expect(page).to have_text "muted: #{conversation.subject}"
#     expect(current_url).to eq organization_conversations_url('raceteam')
#     expect(conversation.recipients.all).to_not include current_user

#     conversation = threadable.conversations.find_by_slug!('how-are-we-going-to-build-the-body')
#     expect(conversation.recipients.all).to include current_user
#     visit organization_conversation_url('raceteam', 'how-are-we-going-to-build-the-body')
#     expect(page).to have_selector '.message'
#     click_on 'mute conversation'
#     expect(page).to have_text "muted: #{conversation.subject}"
#     expect(current_url).to eq organization_conversations_url('raceteam')
#     expect(conversation.recipients.all).to_not include current_user

#     visit organization_conversation_url('raceteam', conversation)
#     expect(page).to have_selector '.message'
#     click_on 'un-mute conversation'
#     expect(page).to have_text "un-muted: #{conversation.subject}"
#     expect(current_url).to eq organization_conversation_url('raceteam', conversation)
#     expect(page).to have_text 'mute conversation'
#     expect(conversation.recipients.all).to include current_user
#   end

#   scenario %(muting a conversation in my email) do
#     organization = threadable.organizations.find_by_slug!('raceteam')
#     current_user = organization.members.who_get_email.first
#     conversation = organization.conversations.latest
#     message      = conversation.messages.latest

#     expect(conversation.recipients.all).to include current_user

#     threadable.emails.send_email(:conversation_message, organization, message, current_user)

#     mute_url = sent_emails.first.urls.map(&:to_s).find{|url| url.include? 'mute'}
#     visit mute_url

#     within_element 'the sign in form' do
#       fill_in 'Email',    :with => current_user.email_address.to_s
#       fill_in 'Password', :with => 'password'
#       click_on 'Sign in'
#     end

#     expect(page).to have_text "muted: #{conversation.subject}"
#     expect(conversation.recipients.all).to_not include current_user
#   end
# end
