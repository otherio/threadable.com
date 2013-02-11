require 'spec_helper'

describe TaskListWidget do

  let(:tasks)     { double(:tasks) }
  let(:arguments) { [tasks] }

  def html_options
    {class: 'custom_class'}
  end

    describe "locals" do
    it "should return the expected hash" do
      subject.locals.should == {
        block: nil,
        presenter: presenter,
        tasks: tasks,
      }
    end
  end

  describe "html_options" do
    it "should return the expected hash" do
      subject.html_options.should == {
        class: "task_list custom_class",
      }
    end
  end

end
