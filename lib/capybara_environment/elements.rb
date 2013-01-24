module CapybaraEnvironment::Elements

  def selector_for name
    case name
    when 'the login form'
      '.login_form'
    end
  end

end
