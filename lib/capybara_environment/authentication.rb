module CapybaraEnvironment::Authentication

  def login_as user
    case Capybara.current_driver
    when :rack_test
      post user_session_path, {
        "user" => {
          "email"    => user.email,
          "password" => "password",
        },
      }
    else
      visit new_user_session_path
      fill_in 'Email', :with => user.email
      fill_in 'Password', :with => 'password'
      click_on 'Sign in'
    end
  end

end
