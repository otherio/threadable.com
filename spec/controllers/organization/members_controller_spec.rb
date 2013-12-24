require 'spec_helper'

describe Organization::MembersController do

  before{ sign_in! find_user_by_email_address('bob@ucsd.example.com') }

  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }

  def valid_params
    {
      format: 'json',
      organization_id: organization.to_param,
    }
  end

  describe "GET index" do
    it "shows a list of users that are members of the organization" do
      get :index, organization_id: organization.to_param
      response.should be_success
      assigns(:members).should =~ organization.members.all
    end

    context "when XHR" do
      it "returns a list of users that are members of the organization as json" do
        xhr :get, :index, valid_params
        response.should be_success
        # this is fucking stupid
        JSON.parse(response.body).should =~ JSON.parse(organization.members.to_json)
      end
    end
  end

  describe "POST create" do

    def valid_params
      super.merge(
        member: {
          name:  'Steve Bushebi',
          email_address: 'steve@bushebi.me',
          message: 'yo join this, dawg',
        }
      )
    end

    def member_hash
      {
        name:          valid_params[:member][:name],
        email_address: valid_params[:member][:email_address],
      }
    end

    def personal_message
      valid_params[:member][:message]
    end

    let(:member){ double(:member) }

    context "when adding the member succeeds" do
      before do
        expect_any_instance_of(Covered::Organization::Members).to receive(:add).
          with(
            name: member_hash[:name],
            email_address: member_hash[:email_address],
            personal_message: personal_message,
          ).and_return(member)
      end
      it "should render the member as json with a created status" do
        post :create, valid_params
        expect(response.status).to eq 201
        expect(response.body).to eq member.to_json
      end
    end

    context "when adding the member raises a Covered::RecordInvalid" do
      before do
        expect_any_instance_of(Covered::Organization::Members).to receive(:add).and_raise(Covered::RecordInvalid)
      end

      it "should render an error in json with an unprocessable entity status" do
        post :create, valid_params
        expect(response.status).to eq 422
        expect(response.body).to eq '{"error":"unable to create user"}'
      end

    end

  end

end
