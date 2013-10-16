class SignInFormWidget < Rails::Widget::Presenter

  arguments :email

  classname('well well-centered')

  option :form_options do
    {
      :url    => @view.sign_in_path,
      :remote => true,
      :html   => {:'data-type' => 'json'},
    }
  end

  option :authentication do
    Authentication.new(email: email)
  end

  option :password_recovery do
    PasswordRecovery.new(email: email)
  end

end
