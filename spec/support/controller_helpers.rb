module RSpec::Rails::ControllerExampleGroup

  def sign_in_as user, remember_me: false
    controller.sign_in! user, remember_me: remember_me
  end

  def sign_out!
    controller.sign_out!
  end

  def covered
    controller.covered
  end

  def current_user
    covered.current_user
  end

end
