require 'spec_helper'

# we will put this back when we turn these features back on.
# feature "Shareworthy" do

#   scenario %(marking a message as shareworthy) do
#     sign_in_as 'tom@ucsd.covered.io'
#     visit organization_conversation_url('raceteam', 'layup-body-carbon')
#     expect(page).to have_selector '.message'
#     within first('.message') do
#       click_on 'shareworthy'
#     end
#     expect(page).to have_selector '.message[shareworthy]'
#     expect(first('.message[shareworthy]')).to eq first('.message')
#     reload!
#     expect(page).to have_selector '.message[shareworthy]'
#     expect(first('.message[shareworthy]')).to eq first('.message')

#     within first('.message[shareworthy]') do
#       click_on 'shareworthy'
#     end
#     expect(page).to_not have_selector '.message[shareworthy]'
#     reload!
#     expect(page).to_not have_selector '.message[shareworthy]'
#   end

# end
