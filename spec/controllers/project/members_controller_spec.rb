require 'spec_helper'

describe Project::MembersController do

  let(:project) { Project.find_by_name("UCSD Electric Racing", include: :members) }
  let(:user)    { project. members.first }

  before do
    sign_in user
  end

  def valid_params
    {:project_id => project.to_param}
  end

  describe "GET user_list" do

    it "returns a list of users" do
      xhr :get, :index, valid_params
      response.should be_success
      response.body.should == project.members.to_json
    end
  end

end
