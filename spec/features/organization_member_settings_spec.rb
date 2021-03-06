require 'spec_helper'

feature "organization member settings" do

  let(:organization){ threadable.organizations.find_by_slug!('raceteam') }

  before do

  end

  def bethany
    organization.members.find_by_user_slug!('bethany-pattern')
  end

  scenario %(unsubscribing and resubscribing) do
    sign_in_as 'bethany@ucsd.example.com'

    expect(bethany).to be_subscribed

    visit_organization_settings

    within '.organization-members' do
      click_on 'Bethany Pattern'
    end

    expect(page).to have_selector '.subscribed.input-switch-on'
    find('.subscribed.input-switch').click

    click_on 'cancel'

    wait_until_expectation do
      expect(bethany).to be_subscribed
    end

    expect(page).to have_selector '.subscribed.input-switch-on'
    find('.subscribed.input-switch').click

    click_on 'Unsubscribe'

    wait_until_expectation do
      expect(bethany).to_not be_subscribed
    end

    expect(page).to have_selector '.subscribed.input-switch-off'
    find('.subscribed.input-switch').click

    wait_until_expectation do
      expect(bethany).to be_subscribed
    end

    expect(page).to have_selector '.subscribed.input-switch-on'
  end


  describe %(changing roles) do
    describe %(as an organization owner) do
      before{ sign_in_as 'alice@ucsd.example.com' }
      scenario %(should be possible for all members other then myself) do
        sign_in_as 'alice@ucsd.example.com'
        visit_organization_settings

        within '.organization-members' do
          click_on 'Alice Neilson'
        end
        expect(page).to_not have_selector 'select.role'

        within '.organization-members' do
          click_on 'Bethany Pattern'
        end
        expect(page).to have_selector 'select.role'
      end
    end
    describe %(as an organization member) do
      before{ sign_in_as 'bethany@ucsd.example.com' }

      scenario %(should not be possible) do
        sign_in_as 'bethany@ucsd.example.com'
        visit_organization_settings

        within '.organization-members' do
          click_on 'Alice Neilson'
        end
        expect(page).to_not have_selector 'select.role'

        within '.organization-members' do
          click_on 'Bethany Pattern'
        end
        expect(page).to_not have_selector 'select.role'
      end
    end
  end

  scenario %(removing a member) do
    sign_in_as 'alice@ucsd.example.com'

    visit_organization_settings

    within '.organization-members' do
      click_on 'Yan Hzu'
    end

    expect(page).to have_text 'Remove this member'

    # for some reason, finding this by its text doesn't work
    within('.danger-zone') { page.find('a').click }

    click_on 'remove'

    wait_until_expectation do
      expect(organization.members.find_by_user_slug('yan-hzu')).to be_nil
    end

    expect(page).to be_at_url organization_members_url('raceteam')
    expect(page).to_not have_text 'Yan Hzu'
  end

  def visit_organization_settings
    within_element 'the sidebar' do
      find('.organization-details').click
      sleep 0.2
      within '.organization-controls' do
        click_on 'Members'
      end
    end
  end
end
