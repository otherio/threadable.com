require 'spec_helper'

describe "task_metadata" do

  let(:task_done){ true }

  let(:doers){
    2.times.map{|i|
      double(:"doer#{i}",
        name: "doer#{i}",
        avatar_url: "/doer#{i}.jpg",
      )
    }
  }

  let :project do
    double(:project,
      to_param: 'project-slug',
    )
  end

  let :task do
    double(:task,
      done?: task_done,
      subject: 'CONVERSATION SUBJECT',
      doers: doers,
      project: project,
      to_param: 'task-slug',
    )
  end

  let(:user){ double(:user) }

  def locals
    {
      task: task,
      user: user,
    }
  end

  it "should equal this brital string" do
    pending
    # TODO replace this with better tests
    return_value.should == "<p class='lead task-title'>\n<i class='icon-ok finished-check'></i>\nCONVERSATION SUBJECT\n</p>\n<div class='container-fluid'>\n<div class='row-fluid'>\n<div class='task-controls span12'>\n<div class='doers-and-muted'>\n<i class='icon-bolt'></i>\ndoers:\n<img alt=\"doer0\" class=\"has-tooltip\" data-toggle=\"tooltip\" src=\"/doer0.jpg\" title=\"doer0\" />\n<img alt=\"doer1\" class=\"has-tooltip\" data-toggle=\"tooltip\" src=\"/doer1.jpg\" title=\"doer1\" />\n<a class='control-link muted pull-right' href=''>\nmuted count\n</a>\n</div>\n<a class='control-link text-info toggle-doer-self' href=''>\n<i class='icon-plus'></i>\nsign me up\n</a>\n&#183;\n<a class='control-link text-info add-others' data-html data-placement='bottom' href=''>\n<i class='icon-user'></i>\nadd others\n</a>\n&#183;\n<a class='control-link text-info schedule-event' href=''>\n<i class='icon-calendar'></i>\nschedule event\n</a>\n&#183;\n<a href=\"/project-slug/conversations/task-slug?conversation%5Bdone%5D=false\" class=\"control-link text-info toggle-done\" data-method=\"PUT\" rel=\"nofollow\"><i class='icon-ok'></i>\nmark as not done\n</a><a class='control-link text-info pull-right mute-task' href=''>\n<i class='icon-volume-off'></i>\nmute conversation\n</a>\n</div>\n</div>\n</div>\n<div class='add-others-popover'>\n<input class='add-others-typeahead' data-provide='typeahead' name='add-others-typeahead' type='text'>\n<h2>things. they are real.</h2>\n</div>\n"
  end

end
