require 'spec_helper'

describe EmailsController, fixtures: false do

  let(:timestamp){ Time.now.to_i.to_s }
  let(:token    ){ SecureRandom.uuid }
  let(:signature){ MailgunSignature.encode(timestamp, token) }
  let :params do
    {
      'signature' => signature,
      'timestamp' => timestamp,
      'token'     => token,
    }
  end

  describe "POST create" do

    context "when the post data has a valid signature" do
      it "should render succesfully" do
        expect(covered.incoming_emails).to receive(:create!).with(params)
        post :create, params
        expect(response).to be_success
        expect(response.body).to be_blank
      end
    end

    context "when the post data does not have a valid signature" do
      let(:signature){ 'badsignature' }
      it "should not render succesfully" do
        expect(covered.incoming_emails).to_not receive(:create!)
        post :create, params
        expect(response).to_not be_success
        expect(response.body).to be_blank
      end
    end

    context 'when the post fails to create an IncomingEmail' do
      it "renders a 400" do
        error = Covered::RecordInvalid.new('BAD!')
        expect(covered.incoming_emails).to receive(:create!).and_raise(error)
        expect(Honeybadger).to receive(:notify).with(error)
        post :create, params
        expect(response.status).to eq 400
        expect(response.body).to be_blank
      end
    end

  end

end
