require 'spec_helper'

describe SignInFormWidget do

  let(:user){ User.last }
  let(:arguments){ [user] }

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
        user: user,
        form_options: {
          :as => :user,
          :url => view.session_path(:user),
          remote: true,
          :html => {:'data-type' => 'json'},
        }
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "sign_in_form custom_class span4 offset4 well",
        widget: "sign_in_form",
      }
    end
  end

end
