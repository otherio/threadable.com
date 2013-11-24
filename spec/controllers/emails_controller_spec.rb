require 'spec_helper'

describe EmailsController do

  let(:params){ create_incoming_email_params }
  let(:fake_incoming_email){ double(:fake_incoming_email, id: 45) }

  describe "POST create" do

    context "when the post data has a valid signature" do
      it "should render succesfully" do
        expect(IncomingEmail).to receive(:create!).with(params: params).and_return(fake_incoming_email)
        expect(ProcessIncomingEmailWorker).to receive(:perform_async).with(covered.env, fake_incoming_email.id)
        post :create, params
        expect(response).to be_success
        expect(response.body).to be_blank
      end
    end

    context "when the post data does not have a valid signature" do
      let(:params){ create_incoming_email_params.merge('signature' => 'badsignature') }
      it "should not render succesfully" do
        expect(IncomingEmail).to_not receive(:create!)
        expect(ProcessIncomingEmailWorker).to_not receive(:perform_async)
        post :create, params
        expect(response).to_not be_success
        expect(response.body).to be_blank
      end
    end

  end

end
