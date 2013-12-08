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
    double(:conversations, all: [
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
    ])
  }

  let(:tasks_all) { conversations.all.select(&:task?) }
  let(:tasks_all_for_user) do
    conversations.all.select(&:task?).select{ |t| t.doers == [current_user] }
  end

  let(:tasks){
    double(:tasks, all_for_user: tasks_all_for_user, all: tasks_all)
  }

  def html_options
    {class: 'custom_class'}
  end

  before do
    conversations.stub(:includes).and_return(conversations)
    view.stub(:current_user).and_return(current_user)
    tasks.stub(:includes).with(:doers).and_return(tasks)
  end

  it_should_behave_like "a widget presenter"

  describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block:             nil,
        presenter:         presenter,
        project:           project,
        conversations:     conversations.all,
        tasks:             tasks.all,
        my_tasks:          [conversations.all[2], conversations.all[5], conversations.all[8]],
        done_tasks:        [conversations.all[2], conversations.all[6], conversations.all[8]],
        not_done_tasks:    [conversations.all[1], conversations.all[3], conversations.all[5], conversations.all[9]],
        my_done_tasks:     [conversations.all[2], conversations.all[8]],
        my_not_done_tasks: [conversations.all[5]],
        with_title:        false,
      }
    end
  end

  describe "html_options" do
    subject{ presenter.html_options }
    it do
      should == {
        class: "tasks_sidebar custom_class",
        widget: "tasks_sidebar",
        'data-conversations' => true,
        'data-with_title' => false,
      }
    end
  end


end
