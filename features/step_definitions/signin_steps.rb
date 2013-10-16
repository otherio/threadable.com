Then(/^I should see the sign in form shake$/) do
  expect(page).to have_selector('.sign_in_form.shake')
end
