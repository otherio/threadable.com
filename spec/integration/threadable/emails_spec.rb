require 'spec_helper'

describe Threadable::Emails do

  let(:emails){ threadable.emails }

  describe 'validating Mail::Message' do

    let(:email)              { Mail.new }
    let(:smtp_envelope_from) { 'jared@other.io' }
    let(:smtp_envelope_to)   { 'ian@other.io' }
    let(:from)               { 'jared@other.io' }
    let(:to)                 { 'ian@other.io' }
    let(:subject)            { 'Hi Ian' }
    let(:body)               { 'You smell nice today!' }
    before do
      email.smtp_envelope_from = smtp_envelope_from if smtp_envelope_from.present?
      email.smtp_envelope_to   = smtp_envelope_to if smtp_envelope_to.present?
      email.from               = from
      email.to                 = to
      email.subject            = subject
      email.body               = body

      expect(emails).to receive(:generate).and_return(email)
    end

    def send!
      emails.send_email(:whatever) # stubbing, stubbing around, stub stub stub stub
    end

    it 'should send the email' do
      expect(email).to receive(:deliver)
      send!
    end

    context 'when the smtp envelope from is bullshit' do
      let(:smtp_envelope_from) { 'jared <jared@other.io' }
      it 'should not send the email' do
        expect(email).to_not receive(:deliver)
        expect{ send! }.to raise_error Threadable::Emails::InvalidEmail, 'invalid envelope from address: "jared <jared@other.io"'
      end
    end

    context 'when the smtp envelope to is bullshit' do
      let(:smtp_envelope_to) { 'jared <jared@other.io>' }
      it 'should not send the email' do
        expect(email).to_not receive(:deliver)
        expect{ send! }.to raise_error Threadable::Emails::InvalidEmail, 'invalid envelope to address: "jared <jared@other.io>"'
      end
    end

    context 'when the from is bullshit' do
      let(:from) { 'jared <jared@other.io' }
      it 'should not send the email' do
        expect(email).to_not receive(:deliver)
        expect{ send! }.to raise_error Threadable::Emails::InvalidEmail, 'invalid from address: "jared <jared@other.io"'
      end
    end

    context 'when the to is bullshit' do
      let(:to) { 'jared <jared@other.io' }
      it 'should not send the email' do
        expect(email).to_not receive(:deliver)
        expect{ send! }.to raise_error Threadable::Emails::InvalidEmail, 'invalid to address: "jared <jared@other.io"'
      end
    end

    context 'when the from is a formatted email address' do
      let(:from) { 'jared <jared@other.io>' }
      it 'should send the email' do
        expect(email).to receive(:deliver)
        send!
      end
    end

    context 'when the to is a formatted email address' do
      let(:to) { 'jared <jared@other.io>' }
      it 'should send the email' do
        expect(email).to receive(:deliver)
        send!
      end
    end

    context 'when the subject is blank' do
      let(:subject) { '' }
      it 'should not send the email' do
        expect(email).to_not receive(:deliver)
        expect{ send! }.to raise_error Threadable::Emails::InvalidEmail, 'invalid subject: is blank'
      end
    end


  end

end
