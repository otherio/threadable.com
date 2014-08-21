require 'spec_helper'

describe Api::OrganizationMembersController, :type => :controller do
  let(:raceteam){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:sfhealth){ threadable.organizations.find_by_slug! 'sfhealth' }

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1, task_id: 1
        expect(response.status).to eq 401
        expect(response.body).to eq '{"error":"Unauthorized"}'
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do
    # get /api/:organization/tasks/:task/members
    describe 'index' do
      context 'when given an organization id' do

        context 'of an organization that the current user is in' do
          it "renders all the members of the organization as json" do
            xhr :get, :index, format: :json, organization_id: raceteam.slug
            expect(response).to be_ok
            expect(response.body).to eq serialize(:organization_members, raceteam.members.all).to_json
          end
        end
        context 'of an organization that the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: sfhealth.slug
            expect(response.status).to eq 404
            expect(response.body).to eq '{"error":"unable to find organization with slug \"sfhealth\""}'
          end
        end
        context 'of an organization that does not exist' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: 'foobar'
            expect(response.status).to eq 404
            expect(response.body).to eq '{"error":"unable to find organization with slug \"foobar\""}'
          end
        end
      end
    end

    describe '#create' do
      context "when given a valid organization id" do
        it "renders the newly invited member as json, and creates the member" do
          member_count = raceteam.members.all.length
          xhr :post, :create, format: :json, organization_id: raceteam.slug, organization_member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 201
          member = raceteam.members.all.find{|m| m.email_address == 'john@varvatos.com'}
          expect(member).to be_present
          expect(response.body).to eq serialize(:organization_members, member).to_json
          expect(raceteam.members.all.length).to eq member_count + 1
        end
      end
      context "when given no email address" do
        it 'renders not acceptable' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, organization_member: { name: "John Varvatos", email_address: "", personal_message: "Hi!" }
          expect(response.body).to eq '{"error":"unable to create user"}'
          expect(response.status).to eq 422
        end
      end
      context "when given an organization id of an organization that does not exist" do
        it 'renders not found' do
          xhr :post, :create, format: :json, organization_id: 'foobar', organization_member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug \"foobar\""}'
        end
      end
      context 'when given an organization id of an organization that the current user is not in' do
        it 'renders not found' do
          xhr :post, :create, format: :json, organization_id: sfhealth.slug, organization_member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug \"sfhealth\""}'
        end
      end
      context 'when given no organization id' do
        it 'renders not acceptable' do
          xhr :post, :create, format: :json, organization_member: { name: "John Varvatos", email_address: "john@varvatos.com", personal_message: "Hi!" }
          expect(response.status).to eq 406
          expect(response.body).to eq '{"error":"param is missing or the value is empty: organization_id"}'
        end
      end
    end
  end

  describe '#destroy' do
    let(:user) { raceteam.members.find_by_email_address('bethany@ucsd.example.com') }

    when_signed_in_as 'alice@ucsd.example.com' do
      context "when given a valid organization id" do
        it "removes the member from the organization" do
          member_count = raceteam.members.all.length
          xhr :delete, :destroy, format: :json, organization_id: raceteam.slug, id: user.id
          expect(response.status).to eq 200
          member = raceteam.members.all.find{|m| m.email_address == 'bethany@ucsd.example.com'}
          expect(member).to_not be_present
          expect(response.body).to eq '{}'
          expect(raceteam.members.all.length).to eq member_count - 1
        end
      end

      context "when given an organization id of an organization that does not exist" do
        it 'renders not found' do
          xhr :delete, :destroy, format: :json, organization_id: 'foobar', id: user.id
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug \"foobar\""}'
        end
      end
      context 'when given an organization id of an organization that the current user is not in' do
        it 'renders not found' do
          xhr :delete, :destroy, format: :json, organization_id: sfhealth.slug, id: user.id
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug \"sfhealth\""}'
        end
      end
      context 'when given no organization id' do
        it 'renders not acceptable' do
          xhr :delete, :destroy, format: :json, id: user.id
          expect(response.status).to eq 406
          expect(response.body).to eq '{"error":"param is missing or the value is empty: organization_id"}'
        end
      end
    end

    when_signed_in_as 'bob@ucsd.example.com' do
      context "when the current user is not an owner" do
        it 'renders not authorized' do
          xhr :delete, :destroy, format: :json, organization_id: raceteam.slug, id: user.id
          expect(response.status).to eq 401
          expect(response.body).to eq '{"error":"You cannot remove members from this organization"}'
        end
      end
    end

  end

  describe '#resend_invitation' do
    let(:user) { raceteam.members.find_by_email_address('bethany@ucsd.example.com') }

    when_signed_in_as 'alice@ucsd.example.com' do
      context "when given a valid organization id" do
        before do
          sent_emails.clear
        end

        it "resends the invitation email when the user is unconfirmed" do
          user.unconfirm!
          xhr :post, :resend_invitation, format: :json, organization_id: raceteam.slug, organization_member_id: user.id
          expect(response.status).to eq 201
          expect(sent_emails.with_subject("You've been invited to UCSD Electric Racing")).to be
        end

        it "does nothing when the user is already confirmed" do
          user.confirm!
          xhr :post, :resend_invitation, format: :json, organization_id: raceteam.slug, organization_member_id: user.id
          expect(response.status).to eq 200
          expect(sent_emails.with_subject("You've been invited to UCSD Electric Racing")).to be_empty
        end
      end

      context "when given an organization id of an organization that does not exist" do
        it 'renders not found' do
          xhr :post, :resend_invitation, format: :json, organization_id: 'foobar', organization_member_id: user.id
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug \"foobar\""}'
        end
      end
      context 'when given an organization id of an organization that the current user is not in' do
        it 'renders not found' do
          xhr :post, :resend_invitation, format: :json, organization_id: sfhealth.slug, organization_member_id: user.id
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug \"sfhealth\""}'
        end
      end
      context 'when given no organization id' do
        it 'renders not acceptable' do
          xhr :post, :resend_invitation, format: :json, organization_member_id: user.id
          expect(response.status).to eq 406
          expect(response.body).to eq '{"error":"param is missing or the value is empty: organization_id"}'
        end
      end
    end

  end


end
