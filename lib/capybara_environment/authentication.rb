module CapybaraEnvironment::Authentication

  def sign_in_as user, remember_me: false
    sign_out!
    visit sign_in_path
    within_element 'the sign in form' do
      fill_in 'Email', :with => user.email
      fill_in 'Password', :with => 'password'
      check 'Remember me' if remember_me
      click_on 'Sign in'
    end
    # not sure why we see this error sometimes but retrying seems to fix it - Jared
    begin
      expect(page).to have_content('Projects')
    rescue Capybara::Webkit::InvalidResponseError
      raise if @capybara_webkit_invalid_response_error_seen
      @capybara_webkit_invalid_response_error_seen = true
      retry
    end
    covered.env["current_user_id"] = user.id
  end

  def sign_out!
    visit sign_out_path
    visit root_path
    page.should have_content('Sign in')
  end

end
