require 'spec_helper'

describe EmailsController do

  def params
    timestamp = "1370817404"
    token = "116d1b6e-3ee0-4f9c-8f77-4b7d10c42ee2"
    {
      'timestamp'        => timestamp,
      'token'            => token,
      'signature'        => MailgunSignature.encode(timestamp, token),
      'message-headers'  => 'message-headers',
      'from'             => 'from',
      'recipient'        => 'recipient',
      'subject'          => 'subject',
      'body-html'        => 'body-html',
      'body-plain'       => 'body-plain',
      'stripped-html'    => 'stripped-html',
      'stripped-text'    => 'stripped-text',
      'attachment-count' => 'attachment-count',
      'attachment-1'     => 'attachment-1',
      'attachment-2'     => 'attachment-2',
      'attachment-3'     => 'attachment-3',
    }
  end

  describe "POST create" do

    context "when the post data has a valid signature" do
      it "should render succesfully" do
        EmailProcessor.should_receive(:encode_attachements).with(params)
        ProcessEmailWorker.should_receive(:enqueue).with(params)
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
        EmailProcessor.should_not_receive(:encode_attachements)
        ProcessEmailWorker.should_not_receive(:enqueue)
        post :create, params
        expect(response).to_not be_success
        expect(response.body).to be_blank
      end
    end

  end

end
