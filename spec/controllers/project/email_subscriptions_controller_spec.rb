require 'spec_helper'

describe Project::EmailSubscriptionsController do

  before{ sign_in! find_user_by_email_address('bob@ucsd.covered.io') }

  let(:project){ current_user.projects.find_by_slug! 'raceteam' }
  let(:member){ project.members.find_by_user_id! current_user.id }

  %w(unsubscribe resubscribe).each do |action|
    describe "GET #{action}" do
      it "should render the auto_post template" do
        get action.to_sym, project_id: project.slug, token: 'FAKETOKEN'
        expect(response).to render_template :auto_post
      end
    end
  end

  describe "POST unsubscribe" do
    let(:token) { ProjectUnsubscribeToken.encrypt(project.id, current_user.id) }

    context "when the member gets email for the project" do
      # bob gets emails for the raceteam project
      before{ sign_in! find_user_by_email_address('bob@ucsd.covered.io') }

      it "should disable emails for the project memebership" do
        expect(member).to be_subscribed
        expect(covered.emails).to receive(:send_email_async).with(:unsubscribe_notice, project.id, member.id)
        post :unsubscribe, project_id: project.slug, token: token
        member.reload
        expect(member).to_not be_subscribed
        expect(response).to render_template(:unsubscribe)
      end
    end

    context "when the member doesnt get email for the project" do
      # jonathan doesnt get emails for the raceteam project
      before{ sign_in! find_user_by_email_address('jonathan@ucsd.covered.io') }

      it "should do nothing but look like it unsubscribed you" do
        expect(member).to_not be_subscribed
        expect(covered.emails).to_not receive(:send_email_async)
        post :unsubscribe, project_id: project.slug, token: token
        expect(response).to render_template(:unsubscribe)
        member.reload
        expect(member).to_not be_subscribed
      end
    end

  end

  describe "POST resubscribe" do
    let(:token) { ProjectResubscribeToken.encrypt(project.id, current_user.id) }

    context "when the member gets email for the project" do
      # bob gets emails for the raceteam project
      before{ sign_in! find_user_by_email_address('bob@ucsd.covered.io') }
      it "should do nothing but look like it resubscribed you" do
        expect(member).to be_subscribed
        post :resubscribe, project_id: project.slug, token: token
        member.reload
        expect(member).to be_subscribed
        expect(response).to render_template(:resubscribe)
      end
    end

    context "when the member doesnt get email for the project" do
      # jonathan doesnt get emails for the raceteam project
      before{ sign_in! find_user_by_email_address('jonathan@ucsd.covered.io') }
      it "should disable emails for the project memebership" do
        expect(member).to_not be_subscribed
        post :resubscribe, project_id: project.slug, token: token
        member.reload
        expect(member).to be_subscribed
        expect(response).to render_template(:resubscribe)
      end
    end

  end

end
