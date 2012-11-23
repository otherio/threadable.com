require 'spec_helper'

describe Test::Api::Project do

  it "should persist projects in memory" do

    project = Test::Api::Project.create({
      name: 'bake Ian a cake'
    })

    Test::Api::Project.find('bake Ian a cake').should == project

  end

end
