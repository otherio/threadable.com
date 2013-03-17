require 'spec_helper'

describe TasksSidebarWidget do

  let(:arguments) { [project] }

  let(:current_user){ double(:current_user) }

  let(:project){
    double(:project,
      conversations: conversations,
      tasks: tasks,
      to_param: 'lick-a-fish'
    )
  }

  let(:conversations){
    [
      double(:"conversation0", :task? => false),
      double(:"conversation1", :task? => true, :done? => false, :doers => []),
      double(:"conversation2", :task? => true, :done? => true,  :doers => [current_user]),
      double(:"conversation3", :task? => true, :done? => false, :doers => []),
      double(:"conversation4", :task? => false),
      double(:"conversation5", :task? => true, :done? => false, :doers => [current_user]),
      double(:"conversation6", :task? => true, :done? => true,  :doers => []),
      double(:"conversation7", :task? => false),
      double(:"conversation8", :task? => true, :done? => true,  :doers => [current_user]),
      double(:"conversation9", :task? => true, :done? => false, :doers => []),
    ]
  }

  let(:tasks){
    conversations.select(&:task?)
  }

  def html_options
    {class: 'custom_class'}
  end

  before do
    view.stub(:current_user).and_return(current_user)
    tasks.stub(:includes).with(:doers).and_return(tasks)
  end

  it_should_behave_like "a widget presenter"

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        project: project,

        conversations: conversations,
        tasks: tasks,
        my_tasks: [conversations[2], conversations[5], conversations[8]],
        done_tasks: [conversations[2], conversations[6], conversations[8]],
        not_done_tasks: [conversations[1], conversations[3], conversations[5], conversations[9]],
        my_done_tasks: [conversations[2], conversations[8]],
        my_not_done_tasks: [conversations[5]],
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "tasks_sidebar custom_class",
      }
    end
  end


end
