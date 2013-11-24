require 'spec_helper'

feature "Confirmation" do

  scenario %(Confirming an account with a password) do
    visit_confirmation_token_for "alice@ucsd.covered.io"
    expect(page).to have_text "Your account has been confirmed!"
    expect_to_be_signed_in_as! "Alice Neilson"
  end

  scenario %(Confirming an account without a password) do
    visit_confirmation_token_for "jonathan@ucsd.covered.io"
    expect(page).to have_text "Your account has been confirmed!"
    expect(current_path).to start_with setup_users_path(token:1)[0..-2]
    expect_to_be_signed_out!
  end

  def visit_confirmation_token_for email_address
    user = find_user_by_email_address(email_address)
    user_confirmation_token = UserConfirmationToken.encrypt(user.id)
    visit confirm_users_path(user_confirmation_token)
  end

end
