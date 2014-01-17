require 'spec_helper'

feature "Adding doers to a task" do

  scenario %(adding doers to a task) do
    sign_in_as 'alice@ucsd.example.com'
    visit my_conversation_url('raceteam', 'make-wooden-form-for-carbon-layup')

    expect(doers).to eq Set[]

    click_element 'the change doers button'
    first('li.member').click
    expect(page).to have_text '+Alice Neilson as a doer'
    click_on 'Send'

    expect(page).to have_text 'added Alice Neilson as a doer'
    expect(doers).to eq Set['Alice Neilson']

    reload!
    expect(page).to have_text 'added Alice Neilson as a doer'
    expect(doers).to eq Set['Alice Neilson']

    click_element 'the change doers button'
    first('li.member').click
    expect(page).to have_text '-Alice Neilson as a doer'
    click_on 'Send'

    expect(page).to have_text 'removed Alice Neilson as a doer'
    expect(doers).to eq Set[]
  end


  def doers
    all('.doers .avatar-small').map{|d| d['title']}.to_set
  end

end
