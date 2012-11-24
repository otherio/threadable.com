require 'spec_helper'

describe Test::Api::Tasks do

  it "should persist projects in memory" do

    project = Project.create!({
      name: 'bake Ian a cake'
    })

    tasks = project.tasks

    tasks.create!({
      name: 'do the cooking by the book'
    })

    tasks.create!({
      name: 'dont be lazy'
    })

    tasks.all.map(&:name).to_set.should == Set[
      'do the cooking by the book',
      'dont be lazy'
    ]

    tasks.find_by_name('do the cooking by the book').name.should == 'do the cooking by the book'
    tasks.find_by_name('dont be lazy').name.should == 'dont be lazy'


    # tasks.doers.add('jared@yourface.com')
  end

end
