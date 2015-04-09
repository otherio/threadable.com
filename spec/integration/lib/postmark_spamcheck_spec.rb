require 'spec_helper'

describe PostmarkSpamcheck, :type => :request do
  let(:email) { 'this is an email' }
  let(:spamcheck) { described_class.new(email) }

  context 'with a successful request' do
    before do
      stub_request(:post, 'http://spamcheck.postmarkapp.com/filter').with(
        body: {email: email, options: 'short'}.to_json,
        headers: {'Content-type' => 'application/json', 'Accept' => 'application/json'},
      ).to_return(
        body: {success: true, score: '1.5'}.to_json,
        headers: {'Content-type' => 'application/json'},
        status: 200,
      )
    end

    it 'sends a request to postmark to get the spam score' do
      expect(spamcheck.score).to eq 1.5
    end
  end

  context 'with a failing HTTP status' do
    before do
      stub_request(:post, 'http://spamcheck.postmarkapp.com/filter').with(
        body: {email: email, options: 'short'}.to_json,
        headers: {'Content-type' => 'application/json', 'Accept' => 'application/json'},
      ).to_return(
        body: 'Fail',
        status: 400,
      )
    end

    it 'raises an exception with whatever information we have' do
      expect{spamcheck.score}.to raise_error Threadable::ExternalServiceError, "Spamcheck failed with error 400: Fail"
    end
  end

  context 'with an application failure' do
    before do
      stub_request(:post, 'http://spamcheck.postmarkapp.com/filter').with(
        body: {email: email, options: 'short'}.to_json,
        headers: {'Content-type' => 'application/json', 'Accept' => 'application/json'},
      ).to_return(
        body: {success: false, message: 'This failed'}.to_json,
        status: 200,
      )
    end

    it 'raises an exception with whatever information we have' do
      expect{spamcheck.score}.to raise_error Threadable::ExternalServiceError, "Spamcheck application error: This failed"
    end
  end

end
