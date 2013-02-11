require 'spec_helper'

describe "task_list" do

  let(:project){ double(:project) }

  let(:tasks){
    5.times.map do |i|
      double(:"task#{i}",
        done?: i > 2,
        project: project,
        subject: "TASK SUBJECT #{i}",
      )
    end
  }

  def locals
    {tasks: tasks}
  end

  it "should render a list of the given tasks" do
    list_elements = html.css('ul > li')
    list_elements.zip(tasks).each do |li, task|
      li[:title].should == task.subject
      checkbox = li.css('input').first
      checkbox[:type].should == 'checkbox'
      (!!checkbox[:checked]).should == task.done?
      link = li.css('a').first
      link[:href].should == project_conversation_url(project, task)
      link.text.should == task.subject
    end
  end

end
