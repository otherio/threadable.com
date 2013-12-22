require 'spec_helper'

describe "task_list" do

  let(:organization){ double(:organization) }

  let(:tasks){
    5.times.map do |i|
      double(:"task#{i}",
        id: i+1,
        done?: i > 2,
        organization: organization,
        subject: "TASK SUBJECT #{i}",
        position: i,
        slug: "#{i}-task"
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
      li[:"data-task-id"].should == task.id
      li[:"data-position"].should == task.position
      li[:"data-slug"].should == task.slug

      link = li.css('a').first
      link[:href].should == organization_conversation_url(organization, task)
      link.text.should == task.subject
      icon_class = link.css('i').first[:class]
      icon_class.should include 'icon-ok'
      icon_class.should include task.done? ? 'finished-check' : 'unfinished-check'
    end
  end

end
