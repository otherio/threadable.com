require 'spec_helper'

# we want to keep this for when we put shareworthy and knowledge back.
# feature "Knowledge" do

#   scenario %(marking a message as knowledge) do
#     sign_in_as 'tom@ucsd.example.com'
#     visit organization_conversation_url('raceteam', 'layup-body-carbon')
#     expect(page).to have_selector '.message'
#     within first('.message') do
#       click_on 'knowledge'
#     end
#     expect(page).to have_selector '.message[knowledge]'
#     expect(first('.message[knowledge]')).to eq first('.message')
#     reload!
#     expect(page).to have_selector '.message[knowledge]'
#     expect(first('.message[knowledge]')).to eq first('.message')

#     within first('.message[knowledge]') do
#       click_on 'knowledge'
#     end
#     expect(page).to_not have_selector '.message[knowledge]'
#     reload!
#     expect(page).to_not have_selector '.message[knowledge]'
#   end

# end
