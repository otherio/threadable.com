require 'spec_helper'

describe InviteModalWidget do

  let(:project)   { double(:project) }
  let(:arguments) { [project] }

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
        project: project,
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "invite_modal custom_class",
      }
    end
  end

end
