require 'spec_helper'

describe "tasks_sidebar" do

  let(:tasks){ double(:tasks) }
  let(:project){ double(:project,
    tasks: tasks,
    to_param: 'lick-a-fish',
  ) }

  before do
    project.tasks.should_receive(:not_done).and_return(:fake_not_done_tasks)
    project.tasks.should_receive(:done).and_return(:fake_done_tasks)

    view.should_receive(:render_widget).with(:task_list, :fake_not_done_tasks)
    view.should_receive(:render_widget).with(:task_list, :fake_done_tasks)
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
