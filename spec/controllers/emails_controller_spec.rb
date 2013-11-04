require 'spec_helper'

describe EmailsController do

  let(:params){ create_incoming_email_params }
  let(:fake_incoming_email){ double(:fake_incoming_email, id: 45) }

  describe "POST create" do

    context "when the post data has a valid signature" do
      it "should render succesfully" do
        expect(Covered::IncomingEmail).to receive(:create!).with(params: params).and_return(fake_incoming_email)
        post :create, params
        expect(response).to be_success
        expect(response.body).to be_blank
        assert_background_job_enqueued(covered, :process_incoming_email, incoming_email_id: 45)
      end
    end

    context "when the post data does not have a valid signature" do
      let(:params){ create_incoming_email_params.merge('signature' => 'badsignature') }
      it "should not render succesfully" do
        expect(Covered::IncomingEmail).to_not receive(:create!)
        post :create, params
        expect(response).to_not be_success
        expect(response.body).to be_blank
        expect(background_jobs.size).to eq 0
      end
    end

  end

end
