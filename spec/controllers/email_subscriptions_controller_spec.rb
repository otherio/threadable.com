require 'spec_helper'

describe EmailSubscriptionsController do

  let(:project) { Project.find_by_name("UCSD Electric Racing", include: :members) }
  let(:user)    { project.members.first }
  let(:token)   { UnsubscribeToken.encrypt(project.id, user.id) }
  let(:project_membership){ user.project_memberships.where(project_id: project.id).first }

  describe "GET unsubscribe" do
    it "renders the page with the unsubscribe js" do
      get :unsubscribe, project_id: project.slug, token: token
      assigns[:project_id].should == project.slug
      assigns[:token].should == token
    end
  end

  describe "POST unsubscribe" do
    before do
      fake_mail = double(:fake_mail)
      UserMailer.should_receive(:unsubscribe_notice).with(
        project: project,
        user: user,
        host: 'test.host',
        port: 80,
      ).and_return(fake_mail)
      fake_mail.should_receive(:deliver)
    end

    it "should unsubscribe the user from getting emails for the project" do
      post :process_unsubscribe, project_id: project.slug, token: token
      assigns[:project].should == project
      assigns[:user].should == user
      assigns[:project_membership].should == project_membership
      project_membership.reload
      project_membership.gets_email.should be_false
    end
  end

  describe "GET subscribe" do
    it "should subscribe the user from getting emails for the project" do
      get :subscribe, project_id: project.slug, token: token
      assigns[:project].should == project
      assigns[:user].should == user
      assigns[:project_membership].should == project_membership
      project_membership.reload
      project_membership.gets_email.should be_true
    end
  end

end
