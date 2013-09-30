require 'spec_helper'

describe "page_navigation example" do

  before{ view.stub current_user: User.last! }

  it_should_behave_like "a widget example"

end
