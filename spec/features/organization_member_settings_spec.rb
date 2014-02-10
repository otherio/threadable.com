require 'spec_helper'

feature "organization member settings" do

  let(:organization){ threadable.organizations.find_by_slug!('raceteam') }

  before do
    sign_in_as 'bethany@ucsd.example.com'
  end

  def member
    organization.members.find_by_user_slug!('bethany-pattern')
  end

  scenario %(unsubscribing and resubscribing) do
    expect(member).to be_subscribed

    within_element 'the sidebar' do
      find('.organization-details').click
      sleep 0.2
      within '.organization-settings' do
        click_on 'Members'
      end
    end
    within '.organization-members' do
      click_on 'Bethany Pattern'
    end

    find('.subscribed.input-switch').click

    wait_until_expectation do
      expect(member).to_not be_subscribed
    end

    find('.subscribed.input-switch').click

    wait_until_expectation do
      expect(member).to be_subscribed
    end
  end
end
