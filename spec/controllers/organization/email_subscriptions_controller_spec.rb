require 'spec_helper'

describe Organization::EmailSubscriptionsController do

  before{ sign_in! find_user_by_email_address('bob@ucsd.example.com') }

  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
  let(:member){ organization.members.find_by_user_id! current_user.id }

  %w(unsubscribe resubscribe).each do |action|
    describe "GET #{action}" do
      it "should render the auto_post template" do
        get action.to_sym, organization_id: organization.slug, token: 'FAKETOKEN'
        expect(response.status).to eq 200
        expect(response.body).to include 'auto_post.submit()'
      end
    end
  end

  describe "POST unsubscribe" do
    let(:token) { OrganizationUnsubscribeToken.encrypt(organization.id, current_user.id) }

    context "when the member gets email for the organization" do
      # bob gets emails for the raceteam organization
      before{ sign_in! find_user_by_email_address('bob@ucsd.example.com') }

      it "should disable emails for the organization membership" do
        expect(member).to be_subscribed
        expect(threadable.emails).to receive(:send_email_async).with(:unsubscribe_notice, organization.id, member.id)
        post :unsubscribe, organization_id: organization.slug, token: token
        member.reload
        expect(member).to_not be_subscribed
        expect(response).to render_template(:unsubscribe)
      end
    end

    context "when the member doesnt get email for the organization" do
      # jonathan doesnt get emails for the raceteam organization
      before{ sign_in! find_user_by_email_address('jonathan@ucsd.example.com') }

      it "should do nothing but look like it unsubscribed you" do
        expect(member).to_not be_subscribed
        expect(threadable.emails).to_not receive(:send_email_async)
        post :unsubscribe, organization_id: organization.slug, token: token
        expect(response).to render_template(:unsubscribe)
        member.reload
        expect(member).to_not be_subscribed
      end
    end

  end

  describe "POST resubscribe" do
    let(:token) { OrganizationResubscribeToken.encrypt(organization.id, current_user.id) }

    context "when the member gets email for the organization" do
      # bob gets emails for the raceteam organization
      before{ sign_in! find_user_by_email_address('bob@ucsd.example.com') }
      it "should do nothing but look like it resubscribed you" do
        expect(member).to be_subscribed
        post :resubscribe, organization_id: organization.slug, token: token
        member.reload
        expect(member).to be_subscribed
        expect(response).to render_template(:resubscribe)
      end
    end

    context "when the member doesnt get email for the organization" do
      # jonathan doesnt get emails for the raceteam organization
      before{ sign_in! find_user_by_email_address('jonathan@ucsd.example.com') }
      it "should disable emails for the organization membership" do
        expect(member).to_not be_subscribed
        post :resubscribe, organization_id: organization.slug, token: token
        member.reload
        expect(member).to be_subscribed
        expect(response).to render_template(:resubscribe)
      end
    end

  end

end
