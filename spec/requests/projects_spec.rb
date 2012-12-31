require 'spec_helper'

describe "Projects" do
  let(:user){ FactoryGirl.create(:user) }
  let(:project) { FactoryGirl.create(:project) }

  before(:each) do
    project.members << user
  end

  describe "GET /projects" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get projects_path, {authentication_token: user.authentication_token}, {'HTTP_ACCEPT' => "application/json"}
      response.status.should be(200)
    end
  end
end
