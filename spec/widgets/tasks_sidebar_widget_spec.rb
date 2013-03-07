require 'spec_helper'

describe TasksSidebarWidget do

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
        class: "tasks_sidebar custom_class",
        showing: "all_tasks",
      }
    end
  end


end
