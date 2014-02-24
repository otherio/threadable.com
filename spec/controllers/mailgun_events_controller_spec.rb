require 'spec_helper'

describe MailgunEventsController, fixtures: false do

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
        expect(Threadable::MailgunEvent).to receive(:call).with(threadable, params)
        post :create, params
        expect(response).to be_success
        expect(response.body).to be_blank
      end

    end

    context "when the post data does not have a valid signature" do
      let(:signature){ 'badsignature' }
      it "should not render succesfully" do
        expect(Threadable::MailgunEvent).to_not receive(:call)
        post :create, params
        expect(response).to_not be_success
        expect(response.body).to be_blank
      end
    end

    context 'when the post fails to process the request' do
      it "renders a 400" do
        exception = Threadable::RecordInvalid.new('BAD!')
        expect(Threadable::MailgunEvent).to receive(:call).and_raise(exception)
        expect(Honeybadger).to receive(:notify).with(exception, context: {})
        post :create, params
        expect(response.status).to eq 400
        expect(response.body).to be_blank
      end
    end

  end

end
