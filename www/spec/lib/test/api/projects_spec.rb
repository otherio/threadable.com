require 'spec_helper'

describe Test::Api::Projects do

  it "should persist projects in memory" do

    project = Test::Api::Projects.create({
      name: 'bake Ian a cake'
    })

    Test::Api::Projects.find_by_name('bake Ian a cake').should == project

  end

end
