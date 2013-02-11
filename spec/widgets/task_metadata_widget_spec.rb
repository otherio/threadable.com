require 'spec_helper'

describe TaskMetadataWidget do

  let(:task) { double(:task) }
  let(:user)         { double(:user) }

  def html_options
    {
      class: 'custom_class',
      task: task,
      user: user,
    }
  end

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        task: task,
        user: user,
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "task_metadata custom_class",
      }
    end
  end

end
