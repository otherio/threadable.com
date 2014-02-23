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

    expect(groups).to eq Set[]

    click_element 'the change groups button'
    first('.group-selector .groups a.badge', text: 'Electronics').click
    expect(page).to have_text 'added this task to +Electronics'

    expect(groups).to eq Set['+Electronics']

    reload!
    expect(page).to have_text 'added this task to +Electronics'
    expect(groups).to eq Set['+Electronics']

    first('.conversation-groups i.uk-icon-times').click
    first('.controls a.approve-button').click
    expect(page).to have_text 'removed this task from +Electronics'

    expect(groups).to eq Set[]
  end


  def groups
    wait_for_ember!
    all('.conversation-groups .badge').map{|d| d.text }.to_set
  end

end
