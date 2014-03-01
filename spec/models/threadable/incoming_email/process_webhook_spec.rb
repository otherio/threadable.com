require 'spec_helper'

describe Threadable::IncomingEmail::ProcessWebhook do

  subject{ described_class }

  def call!
    described_class.call(threadable, webhook_url, params)
  end

  let :original_params do
    create_incoming_email_params(
      body_html:       '<h1>hello there</h1>',
      body_plain:      'hello there',
      stripped_html:   '',
      stripped_text:   '',
    )
  end

  let :params do
    original_params.dup
  end

  let :webhook_server_session do
    Capybara::Session.new(Capybara.javascript_driver, webhook_server)
  end

  let :webhook_url do
    "http://example.com/webhook_url"
  end

  describe 'posts the mailgun params to the webhook url' do
    context 'when the request returns a response' do
      before do
        expect(HTTParty).to receive(:post).with(webhook_url, body: params).and_return(response)
        response.stub code: response_code
      end

      context 'and response contains valid JSON' do
        let(:response_code){ 200 }
        let :response do
          params.dup.update(
            'body-html'     => "WEBHOOKED body-html",
            'body-plain'    => "WEBHOOKED body-plain",
            'stripped-html' => "WEBHOOKED stripped-html",
            'stripped-text' => "WEBHOOKED stripped-text",
          )
        end
        it 'updates the params with the orignial values and the new values' do
          expect(threadable).to_not receive(:report_exception!)
          call!
          expect_params_to_be_updated!
        end
      end

      context 'and response contains invalid JSON' do
        let(:response_code){ 500 }
        let :response do
          "<h1>error</h1>"
        end
        it 'reports the error and does nothing to the params' do
          expect(threadable).to receive(:report_exception!).with{|exception, context|
            expect(exception).to be_a described_class::InvalidResponse
            expect(exception.message).to eq %(invalid response from #{webhook_url}. code: 500, body: "<h1>error</h1>")
            expect(context).to eq(incoming_email_webhook_failed: true)
          }
          call!
          expect_params_to_not_be_updated!
        end
      end

    end

    context 'when the request raises an error' do
      let(:exception){ StandardError.new('internet is down') }
      before do
        expect(HTTParty).to receive(:post).with(webhook_url, body: params).and_raise(exception)
      end
      it 'reports the error and does nothing to the params' do
        expect(threadable).to receive(:report_exception!).with(exception, incoming_email_webhook_failed: true)
        call!
        expect_params_to_not_be_updated!
      end
    end
  end

  def expect_params_to_be_updated!
    original_params.keys.each do |param|
      if described_class::MUTABLE_PARAMS.include? param
        expect(params[param]).to eq "WEBHOOKED #{param}"
      else
        expect(params[param]).to eq original_params[param]
      end
    end
    described_class::MUTABLE_PARAMS.each do |param|
      expect(params["BEFORE_WEBHOOK_#{param}"]).to eq original_params[param]
    end
  end

  def expect_params_to_not_be_updated!
    expect(params).to eq original_params
  end

end
