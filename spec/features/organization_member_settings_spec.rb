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

  scenario %(ungrouped mail delivery) do
    sign_in_as 'bethany@ucsd.example.com'

    expect(bethany.ungrouped_mail_delivery).to eq :each_message

    visit_organization_settings

    within '.organization-members' do
      click_on 'Bethany Pattern'
    end

    expect(page).to have_selector '.uk-active', text: 'each message'

    click_on 'no mail'
    expect(page).to have_selector '.uk-active', text: 'no mail'

    wait_until_expectation do
      expect(bethany.ungrouped_mail_delivery).to eq :no_mail
    end

    click_on 'daily summary'
    expect(page).to have_selector '.uk-active', text: 'daily summary'

    wait_until_expectation do
      expect(bethany.ungrouped_mail_delivery).to eq :in_summary
    end

    click_on 'each message'
    expect(page).to have_selector '.uk-active', text: 'each message'

    wait_until_expectation do
      expect(bethany.ungrouped_mail_delivery).to eq :each_message
    end

  end


  def visit_organization_settings
    within_element 'the sidebar' do
      find('.organization-details').click
      sleep 0.2
      within '.organization-settings' do
        click_on 'Members'
      end
    end
  end
end
