require 'spec_helper'

describe Test::Api::Task do

  it "should persist projects in memory" do

    project = Test::Api::Project.create({
      name: 'bake Ian a cake'
    })

    tasks = project.tasks

    tasks.create({
      name: 'do the cooking by the book'
    })

    tasks.create({
      name: 'dont be lazy'
    })

    tasks.get.map(&:name).to_set.should == Set[
      'do the cooking by the book',
      'dont be lazy'
    ]

  end

end
