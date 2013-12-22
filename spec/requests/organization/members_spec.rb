require 'spec_helper'

describe "organization members" do

  before{ sign_in_as 'alice@ucsd.covered.io' }
  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }

  describe "reading members of a organization" do
    it "should work" do
      get organization_members_url(organization, format: :json)
      expect(response).to be_success
      expect(response.body).to eq organization.members.all.to_json
    end
  end

  context "adding an existing user to the organization" do
    let(:user){ covered.users.find_by_email_address('marcus@sfhealth.example.com') }

    def post!
      expect(organization.members).to_not include user
      expect{
        post organization_members_url(organization, format: :json), {member: member_params}
        expect(response).to be_success
      }.to_not change{ covered.users.count }
      member = organization.members.find_by_user_id(user.id)
      expect(response.body).to eq member.to_json
      expect(organization.members).to include user
      expect(member).to be_the_same_user_as user

      assert_tracked(current_user.id, "Added User",
        "Invitee"               => user.id,
        "Organization"               => organization.id,
        "Organization Name"          => "UCSD Electric Racing",
        "Sent Join Notice"      => true,
        "Sent Personal Message" => true,
      )

      assert_background_job_enqueued SendEmailWorker, args: [
        covered.env, "join_notice", organization.id, user.id, member_params[:message]
      ]
      drain_background_jobs!
      expect( sent_emails.join_notices('UCSD Electric Racing').to(user.email_address) ).to be_present
    end

    context 'by id' do
      let :member_params do
        {
          id: user.id,
          message: 'hey Marcus, we need some medical support on this',
        }
      end
      it 'adds the existing user to the organization' do
        post!
      end
    end

    context 'by email address' do
      let :member_params do
        {
          name: user.name,
          email_address: user.email_address,
          message: 'hey Marcus, we need some medical support on this',
        }
      end
      it 'adds the existing user to the organization' do
        post!
      end
      context 'that has non ascii characters' do
        let :member_params do
          {
            name: user.name,
            email_address: "\xEF\xBB\xBF#{user.email_address}\xEF\xBB\xBF",
            message: 'hey Marcus, we need some medical support on this',
          }
        end
        it 'adds the existing user to the organization' do
          post!
        end
      end
    end

    context 'when the user is already a member of the organization' do
      let(:user){ covered.users.find_by_email_address('bethany@ucsd.covered.io') }

      def post!
        expect(organization.members).to include user
        expect{
          post organization_members_url(organization, format: :json), {member: member_params}
          expect(response.status).to eq 422
        }.to_not change{ covered.users.count }
        expect(response.body).to eq %({"error":"user is already a member"})
        expect(organization.members).to include user
        expect(background_jobs).to be_empty
        expect(sent_emails).to be_empty
        expect(trackings).to be_empty
      end

      context 'by id' do
        let :member_params do
          {
            id: user.id,
            message: 'hey Marcus, we need some medical support on this',
          }
        end
        it 'responds with status unprocessable_entity' do
          post!
        end
      end

      context 'by email address' do
        let :member_params do
          {
            name: user.name,
            email_address: user.email_address,
            message: 'hey Marcus, we need some medical support on this',
          }
        end
        it 'responds with status unprocessable_entity' do
          post!
        end

        context 'that has non ascii characters' do
          let :member_params do
            {
              name: user.name,
              email_address: "\xEF\xBB\xBF#{user.email_address}\xEF\xBB\xBF",
              message: 'hey Marcus, we need some medical support on this',
            }
          end
          it 'responds with status unprocessable_entity' do
            post!
          end
        end

      end

    end
  end



  context "adding a new user to the organization" do

    let(:email_address){ 'larry@bm.org' }
    let :member_params do
      {
        name: 'Larry Harvey',
        email_address: email_address,
        message: 'nice desert party bro!',
      }
    end

    def post!
      expect{
        post organization_members_url(organization, format: :json), {member: member_params}
        expect(response).to be_success
      }.to change{ covered.users.count }.by(1)

      larry = organization.members.find_by_user_slug!('larry-harvey')
      expect(larry).to be_present
      expect(response.body).to eq larry.to_json

      assert_tracked(current_user.id, "Added User",
        "Invitee"               => larry.id,
        "Organization"               => organization.id,
        "Organization Name"          => "UCSD Electric Racing",
        "Sent Join Notice"      => true,
        "Sent Personal Message" => true,
      )

      assert_background_job_enqueued SendEmailWorker, args: [
        covered.env, "join_notice", organization.id, larry.id, 'nice desert party bro!'
      ]
      drain_background_jobs!
      expect( sent_emails.join_notices('UCSD Electric Racing').to('larry@bm.org') ).to be_present
    end

    it 'adds the existing user to the organization' do
      post!
    end

    context 'with an email that has non ascii characters' do
      let(:email_address){ "\xEF\xBB\xBFlarry@bm.org" }
      it 'adds the existing user to the organization' do
        post!
      end
    end

    context 'with an invalid email address' do
      let(:email_address){ 'larry@bm' }
      it 'responds with status unprocessable_entity' do
        expect{
          post organization_members_url(organization, format: :json), {member: member_params}
          expect(response.status).to eq 422
        }.to_not change{ covered.users.count }
        expect(response.body).to eq %({"error":"unable to create user"})
        expect(background_jobs).to be_empty
        expect(sent_emails).to be_empty
        expect(trackings).to be_empty
      end
    end

  end

  describe "removing a member from a organization" do
    let(:member){ organization.members.all.last }
    it "should work" do
      delete organization_member_url(organization, member, format: :json)
      expect(response).to be_success
      expect(organization.members).to_not include member
      expect(response.body).to be_blank
      assert_tracked(current_user.id, "Removed User",
        "Removed User" => member.id,
        "Organization"      => organization.id,
        "Organization Name" => "UCSD Electric Racing"
      )
      expect(background_jobs).to be_empty
      expect(sent_emails).to be_empty
    end
  end

end
