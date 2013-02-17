require 'spec_helper'

describe InvitesController do

  let(:project) { Project.find_by_name("UCSD Electric Racing", include: :members) }
  let(:user)    { project.members.first }

  before do
    sign_in user
  end

  def params
    {
      format:     'json',
      project_id: project.to_param,
    }
  end

  describe "#create" do

    let!(:user_count){ User.count }

    context "when given info for a user that we haven't seen" do

      def params
        super.merge(
          invite: {
            name:  'Tord Boontje',
            email: 'tord@tordboontje.com',
          }
        )
      end

      it "should create a new user record and add them as a member to the project" do
        post :create, params
        response.should be_success
        User.count.should == user_count + 1
        invited_user = User.last
        invited_user.name.should == 'Tord Boontje'
        invited_user.email.should == 'tord@tordboontje.com'
        response.body.should == invited_user.to_json
        project.members.reload.should include invited_user
      end

    end

    context "when given info for an existing user" do

      let(:invited_user){ (User.all - project.members).last }

      def params
        super.merge(
          invite: {
            name:  invited_user.name,
            email: invited_user.email,
          }
        )
      end

      it "should create a new user record and add them as a member to the project" do
        post :create, params
        response.should be_success
        User.count.should == user_count
        response.body.should == invited_user.to_json
        project.members.reload.should include invited_user
      end

      context "that is already a member of the project" do
        let(:invited_user){ project.members.last }

        it "should error" do
          post :create, params
          response.status.should == 400
          project.members.reload.should include invited_user
        end

      end

    end

  end

end
