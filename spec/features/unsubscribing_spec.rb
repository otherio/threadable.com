require "spec_helper"

feature "Unsubscribing" do

  scenario "Users can unsubscribe" do
    sign_in_as 'yan@ucsd.example.com'
    visit organization_unsubscribe_url_for 'raceteam'
    expect(page).to have_text "We just unsubscribed Yan Hzu from UCSD Electric Racing"
    click_link "click here to resubscribe!"
    expect(page).to have_text "We just subscribed Yan Hzu to UCSD Electric Racing"
  end

  def organization_unsubscribe_url_for organization_slug
    organization = current_user.organizations.find_by_slug!(organization_slug)
    organization_unsubscribe_token = OrganizationUnsubscribeToken.encrypt(organization.id, current_user.id)
    organization_unsubscribe_path(organization_slug, organization_unsubscribe_token)
  end

end
