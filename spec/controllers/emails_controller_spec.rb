require 'spec_helper'

describe EmailsController do

  let(:params){ create_incoming_email_params }

  describe "POST create" do

    context "when the post data has a valid signature" do
      it "should render succesfully" do
        fake_incoming_email = double(:fake_incoming_email, id: 45)
        IncomingEmail.should_receive(:create!).with(params: params).and_return(fake_incoming_email)
        ProcessEmailWorker.should_receive(:enqueue).with(incoming_email_id: 45)
        post :create, params

        expect(response).to be_success
        expect(response.body).to be_blank
      end
    end

    context "when the post data does not have a valid signature" do
      def params
        super.merge('signature' => 'badsignature')
      end
      it "should not render succesfully" do
        IncomingEmail.should_not_receive(:create!)
        ProcessEmailWorker.should_not_receive(:enqueue)
        post :create, params
        expect(response).to_not be_success
        expect(response.body).to be_blank
      end
    end

  end

end
