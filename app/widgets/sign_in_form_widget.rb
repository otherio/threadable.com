class SignInFormWidget < Rails::Widget::Presenter

  arguments :authentication, :password_recovery

  classname('well well-centered')

  option :form_options do
    {
      :url    => @view.sign_in_path,
      :remote => true,
      :html   => {:'data-type' => 'json'},
    }
  end

end
