class SignInFormWidget < Rails::Widget::Presenter

  arguments :user

  classname('well well-centered')

  option :form_options do
    {
      :as => :user,
      :url => @view.session_path(:user),
      remote: true,
      :html => {:'data-type' => 'json'},
    }
  end

end
