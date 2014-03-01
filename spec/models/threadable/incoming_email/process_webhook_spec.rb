require 'spec_helper'

describe Threadable::IncomingEmail::ProcessWebhook do

  subject{ described_class }
  delegate :call, to: :subject

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

  # let :webhook_server do
  #   Class.new(Sinatra::Base) do
  #     post '/threadable_hook' do
  #       content_type :json
  #       params.keys.each do |key|
  #         next unless params[key].is_a?(String)
  #         params[key] = "HOOKED! #{params[key]}"
  #       end
  #       params.to_json
  #     end
  #   end
  # end

  let :webhook_server_session do
    Capybara::Session.new(Capybara.javascript_driver, webhook_server)
  end

  let :webhook_url do
    "http://example.com/webhook_url"
    # webhook_server_session.visit '/'
    # "#{webhook_server_session.current_url}threadable_hook"
  end

  let :response do
    double(:response)
  end

  before do
    expect(HTTParty).to receive(:post).with(webhook_url, body: params).and_return(response)
    response.stub code: response_code
  end

  describe 'posts the mailgun params to the webhook url' do
    context 'when the response contains valid JSON' do
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
        call(webhook_url, params)
        expect_params_to_be_updated!
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

end
