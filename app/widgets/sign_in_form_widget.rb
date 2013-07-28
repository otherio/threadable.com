class SignInFormWidget < Rails::Widget::Presenter

  arguments :user

  def init
    @html_options.add_classname('well')
  end

  option :form_options do
    {
      :as => :user,
      :url => @view.session_path(:user),
      remote: true,
      :html => {:'data-type' => 'json'},
    }
  end

end
