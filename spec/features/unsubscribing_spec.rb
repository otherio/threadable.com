require "spec_helper"

feature "Unsubscribing" do

  # scenario "Users who are not web enabled should be able web enable their account" do
  #   i_am 'yan@ucsd.covered.io'
  #   visit project_unsubscribe_url_for 'raceteam'
  #   expect(page).to have_text "We just unsubscribed Alice Neilson from UCSD Electric Racing"
  #   click_link "click here to resubscribe!"
  #   expect(page).to have_text "We just subscribed Alice Neilson to UCSD Electric Racing"
  # end

  # def project_unsubscribe_url_for project_slug
  #   project = current_user.projects.find_by_slug!(project_slug)
  #   project_unsubscribe_token = OrganizationUnsubscribeToken.encrypt(project.id, current_user.id)
  #   project_unsubscribe_path(project_slug, project_unsubscribe_token)
  # end

end
