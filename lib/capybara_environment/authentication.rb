module CapybaraEnvironment::Authentication

  def sign_out!
    visit sign_out_path
    visit root_path
    page.should have_content('Sign in')
  end

  def sign_in_as user
    case Capybara.current_driver
    when :rack_test
      sign_in_via_post_as user
    else
      sign_in_via_capybara_as user
    end
  end

  def sign_in_via_post_as user, remember_me: false
    post sign_in_path, {
      "authentication" => {
        "email"       => user.email,
        "password"    => "password",
        "remember_me" => remember_me ? 0 : 1
      },
    }
    expect(response).to be_success
  end

  def sign_in_via_capybara_as user, remember_me: false
    sign_out!
    visit sign_in_path
    within_element 'the sign in form' do
      fill_in 'Email', :with => user.email
      fill_in 'Password', :with => 'password'
      check 'Remember me' if remember_me
      click_on 'Sign in'
    end
    expect(page).to have_content('Projects')
  end

end
