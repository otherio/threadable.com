class LoginFormWidget < Widgets::Base

  def default_options
    {
      :session => Session.new
    }
  end

end
