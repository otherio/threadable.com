require 'spec_helper'

describe Project do

  it "should do all the things" do

    project = Project.new(
      name: "Bake a cake",
      slug: "bake-a-cake",
      description: "we want cake now!",
    )

    project.should_not be_persisted
    project.id.should be_nil

    project.name.should == "Bake a cake"
    project.slug.should == "bake-a-cake"
    project.description.should == "we want cake now!"


    project.save

    project.should be_persisted


    task = project.tasks.new({
      name: 'buy some flour',
      slug: 'buy-some-flour',
    })

    task.project.should == project
    task.project_id.should == project.id

    task.should_not be_persisted
    task.id.should be_nil

    task.save

    task.should be_persisted
    task.id.should_not be_nil

    # project = Project.find_by_id(project.id)
    # project.tasks.all.should == [task]

  end

end
