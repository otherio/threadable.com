require 'spec_helper'

feature "Adding doers to a task" do

  scenario %(adding doers to a task) do
    sign_in_as 'alice@ucsd.covered.io'
    visit project_conversation_url('raceteam', 'make-wooden-form-for-carbon-layup')

    expect(doers).to eq Set[]

    click_on 'add/remove other'
    click_on 'Yan Hzu'
    expect(page).to have_text 'Notice! Yan Hzu have been added as a doer.'
    expect(doers).to eq Set['Yan Hzu']

    reload!
    expect(doers).to eq Set['Yan Hzu']

    click_on 'add/remove other'
    click_on 'Yan Hzu'
    expect(page).to have_text 'Notice! Yan Hzu have been removed as a doer.'

    expect(doers).to eq Set[]
  end


  def doers
    all('.doers .avatar').map(&:text).to_set
  end

end
