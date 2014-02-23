require 'spec_helper'

feature "Adding doers to a task" do

  scenario %(adding doers to a task) do
    sign_in_as 'alice@ucsd.example.com'
    resize_window_to :large

    within_element 'the sidebar' do
      click_on 'My Conversations'
    end
    within_element 'the conversations pane' do
      click_on 'Conversations'
      click_on 'make wooden form for carbon layup'
    end

    expect(page).to be_at_url conversation_url('raceteam', 'my', 'make-wooden-form-for-carbon-layup')

    expect(doers).to eq Set[]

    click_element 'the change doers button'
    first('.doer-selector li.member a', text: 'Alice Neilson').click
    expect(page).to have_text '&add Alice Neilson as a doer'
    click_on 'Update'

    expect(page).to have_text 'added Alice Neilson as a doer'
    expect(doers).to eq Set['Alice Neilson']

    reload!
    expect(page).to have_text 'added Alice Neilson as a doer'
    expect(doers).to eq Set['Alice Neilson']

    click_element 'the change doers button'
    first('.doer-selector li.member a', text: 'Alice Neilson').click
    expect(page).to have_text '&remove Alice Neilson as a doer'
    click_on 'Update'

    expect(page).to have_text 'removed Alice Neilson as a doer'
    expect(doers).to eq Set[]
  end


  def doers
    wait_for_ember!
    all('.doers .avatar').map{|d| d['title'] }.to_set
  end

end
