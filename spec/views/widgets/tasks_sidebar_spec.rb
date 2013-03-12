require 'spec_helper'

describe "tasks_sidebar" do

  let(:current_user){ double(:current_user) }

  let(:project){
    double(:project, tasks: tasks, to_param: 'lick-a-fish')
  }

  let(:tasks){
    [
      double(:"task0", :done? => true,  :doers => []),
      double(:"task1", :done? => false, :doers => []),
      double(:"task2", :done? => true,  :doers => [current_user]),
      double(:"task3", :done? => false, :doers => []),
      double(:"task4", :done? => true,  :doers => []),
      double(:"task5", :done? => false, :doers => [current_user]),
      double(:"task6", :done? => true,  :doers => []),
      double(:"task7", :done? => false, :doers => []),
      double(:"task8", :done? => true,  :doers => [current_user]),
      double(:"task9", :done? => false, :doers => []),
    ]
  }

  before do
    view.stub(:current_user){ current_user }
    project.tasks.should_receive(:includes).with(:doers).and_return(tasks)


    view.should_receive(:render_widget).with(:task_list, [
      tasks[1], tasks[3], tasks[5], tasks[7], tasks[9]
    ], class: 'sortable')
    view.should_receive(:render_widget).with(:task_list, [
      tasks[0], tasks[2], tasks[4], tasks[6], tasks[8]
    ])
    view.should_receive(:render_widget).with(:task_list, [
      tasks[5]
    ], class: 'sortable')
    view.should_receive(:render_widget).with(:task_list, [
      tasks[2], tasks[8]
    ])
  end

  def locals
    {
      project: project,
    }
  end

  describe "form action" do
    subject{ html.css('form').first[:action] }
    it {should == '/lick-a-fish/tasks'}
  end

end
