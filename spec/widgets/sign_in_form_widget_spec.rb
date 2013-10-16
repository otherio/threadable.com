require 'spec_helper'

describe SignInFormWidget do

  let(:email){ 'bob@bob.com' }
  let(:arguments){ [email] }

  let(:authentication){ Authentication.new(email: email) }
  let(:password_recovery){ PasswordRecovery.new(email: email) }

  def html_options
    {class: 'custom_class'}
  end

  it_should_behave_like "a widget presenter"

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        email: email,
        authentication: authentication,
        password_recovery: password_recovery,
        form_options: {
          url: view.sign_in_path,
          remote: true,
          html: {:'data-type' => 'json'},
        }
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "sign_in_form custom_class well well-centered",
        widget: "sign_in_form",
      }
    end
  end

end
