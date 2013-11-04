When(/^I click an account confirmation link for "(.*?)"$/) do |email_address|
  user = Covered::User.with_email(email_address).first!
  user_confirmation_token = UserConfirmationToken.encrypt(user.id)
  visit confirm_users_path(user_confirmation_token)
end
