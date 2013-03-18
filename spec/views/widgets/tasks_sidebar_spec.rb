require 'spec_helper'

describe "tasks_sidebar" do

  let(:project){ double(:project, to_param: 'lick-a-fish') }

  let(:conversations){
    [
      double(:"conversation0", id: 0, :new_record? => false, :subject => 'conversation0', project: project, :task? => true, :done? => true),
      double(:"conversation1", id: 1, :new_record? => true,  :subject => 'conversation1', project: project, :task? => false),
      double(:"conversation2", id: 2, :new_record? => false, :subject => 'conversation2', project: project, :task? => true, :done? => false),
      double(:"conversation3", id: 3, :new_record? => false, :subject => 'conversation3', project: project, :task? => false),
    ]
  }

  let(:tasks) { double(:tasks) }
  let(:my_tasks) { double(:my_tasks) }
  let(:done_tasks) { double(:done_tasks) }
  let(:not_done_tasks) { double(:not_done_tasks) }
  let(:my_done_tasks) { double(:my_done_tasks) }
  let(:my_not_done_tasks) { double(:my_not_done_tasks) }

  def locals
    {
      project: project,
      conversations: conversations,
      tasks: tasks,
      my_tasks: my_tasks,
      done_tasks: done_tasks,
      not_done_tasks: not_done_tasks,
      my_done_tasks: my_done_tasks,
      my_not_done_tasks: my_not_done_tasks,
      with_title: false,
    }
  end


  before do
    view.should_receive(:render_widget).with(:task_list, not_done_tasks, class: 'sortable')
    view.should_receive(:render_widget).with(:task_list, done_tasks)
    view.should_receive(:render_widget).with(:task_list, my_not_done_tasks, class: 'sortable')
    view.should_receive(:render_widget).with(:task_list, my_done_tasks)
  end

  describe "form action" do
    subject{ html.css('form').first[:action] }
    it {should == '/lick-a-fish/tasks'}
  end

  it "should be a think" do
    conversation_elements = html.css('.conversation')
    conversation_elements.size.should == 3
    conversation_elements[0][:'data-conversation-id'].should == "0"
    conversation_elements[1][:'data-conversation-id'].should == "2"
    conversation_elements[2][:'data-conversation-id'].should == "3"
    conversation_elements[0].css('a').first[:href].should == project_conversation_url(project, conversations[0])
    conversation_elements[1].css('a').first[:href].should == project_conversation_url(project, conversations[2])
    conversation_elements[2].css('a').first[:href].should == project_conversation_url(project, conversations[3])
  end

end
