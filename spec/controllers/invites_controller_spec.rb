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

    shared_examples_for :a_sender_of_invite_notices do
      it "should send the user an email asking them if they want email for this project" do
        fake_mail = double(:fake_mail)

        UserMailer.should_receive(:invite_notice).with(
          project: project,
          sender: user,
          user: kind_of(User),
          host: 'test.host',
          invite_message: params[:invite][:invite_message],
          port: 80,
        ).and_return(fake_mail)
        fake_mail.should_receive(:deliver)

        post :create, params
      end
    end

    context "when given info for a user that we haven't seen" do
      def params
        super.merge(
          invite: {
            name:  'Tord Boontje',
            email: 'tord@tordboontje.com',
            invite_message: 'You are a jerk, hang out with us',
          }
        )
      end

      it_behaves_like :a_sender_of_invite_notices

      it "should create a new user record and add them as a member to the project" do
        post :create, params
        response.should be_success
        User.count.should == user_count + 1
        invited_user = User.last
        invited_user.name.should == 'Tord Boontje'
        invited_user.email.should == 'tord@tordboontje.com'
        response.body.should == invited_user.to_json
        project.members.reload.should include invited_user
        invited_user.project_memberships.last.gets_email.should be_false
      end
    end

    context "when given info for an existing user" do
      let(:invited_user){ (User.all - project.members).last }

      def params
        super.merge(
          invite: {
            name:  invited_user.name,
            email: invited_user.email,
            invite_message: 'You are a jerk, hang out with us',
          }
        )
      end

      it_behaves_like :a_sender_of_invite_notices

      it "should create a new user record and add them as a member to the project" do
        post :create, params
        response.should be_success
        User.count.should == user_count
        response.body.should == invited_user.to_json
        project.members.reload.should include invited_user
        invited_user.project_memberships.last.gets_email.should be_false
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
