require 'spec_helper'

feature "Members" do

  scenario %(I want to see a list of members for the current organization) do
    sign_in_as 'tom@ucsd.example.com'
    visit organization_conversation_url('raceteam', 'layup-body-carbon')
    click_on "Members"
    expect(page).to have_link 'Alice Neilson'
    expect(page).to have_link 'Tom Canver'
    expect(page).to have_link 'Yan Hzu'
    expect(page).to have_link 'Bethany Pattern'
    expect(page).to have_link 'Bob Cauchois'
    expect(page).to have_link 'Jonathan Spray'
  end

end
