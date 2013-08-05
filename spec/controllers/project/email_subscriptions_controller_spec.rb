require 'spec_helper'

describe Project::EmailSubscriptionsController do

  let(:project) { Project.where(name: "UCSD Electric Racing").includes(:members).first! }
  let(:user)    { project.members.first! }
  let(:project_membership){ user.project_memberships.where(project_id: project.id).first! }
  let(:email)   { double(:email) }

  %w(unsubscribe resubscribe).each do |action|
    describe "GET #{action}" do
      it "should render the auto_post template" do
        get action.to_sym, project_id: project.slug, token: 'FAKETOKEN'
        expect(response).to render_template :auto_post
      end
    end
  end

  describe "POST unsubscribe" do
    before do
      project_membership.update_attribute(:gets_email, true)
    end

    let(:token) { ProjectUnsubscribeToken.encrypt(project_membership.id) }
    it "should disable emails for the project memebership" do
      expect(ProjectMembershipMailer).to receive(:unsubscribe_notice).with(project_membership).and_return(email)
      expect(email).to receive(:deliver)

      post :unsubscribe, project_id: project.slug, token: token
      project_membership.reload
      expect(project_membership.gets_email?).to be_false
      expect(response).to render_template(:unsubscribe)
    end
  end

  describe "POST resubscribe" do
    before do
      project_membership.update_attribute(:gets_email, false)
    end

    let(:token) { ProjectResubscribeToken.encrypt(project_membership.id) }
    it "should disable emails for the project memebership" do
      post :resubscribe, project_id: project.slug, token: token
      project_membership.reload
      expect(project_membership.gets_email?).to be_true
      expect(response).to render_template(:resubscribe)
    end
  end

end
