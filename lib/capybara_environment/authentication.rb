module CapybaraEnvironment::Authentication

  def login_as user
    case Capybara.current_driver
    when :rack_test
      login_via_post_as user
    else
      login_via_capybara_as user
    end
  end

  def login_via_post_as user
    post user_session_path, {
      "user" => {
        "email"    => user.email,
        "password" => "password",
      },
    }
  end

  def login_via_capybara_as user
    visit new_user_session_path
    within('form#new_user') do
      fill_in 'Email', :with => user.email
      fill_in 'Password', :with => 'password'
      click_on 'Sign in'
    end
    expect(page).to have_content('Projects')
  end

end
