module CapybaraEnvironment::Elements

  def selector_for name
    case name
    when 'the navbar'
      '.page_navigation'
    when 'the login form'
      'form.new_user'
    when 'the modal'
      '.modal'
    end
  end

end
