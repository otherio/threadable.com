Given /^I am not logged in$/ do
  sign_out!
end

Given /^I am "(.*?)"$/ do |name|
  @user = Covered::User.where(name: name).first!
  sign_in_as(@user)
end

Then /^I should be signed in as "(.*?)"$/ do |name|
  find('.page_navigation .current_user a').should have_content name
end

Then /^I should not be signed in$/ do
  within_element 'the navbar' do
    expect(page).to have_content 'Sign in'
    expect(page).to have_content 'Sign up'
  end
end
