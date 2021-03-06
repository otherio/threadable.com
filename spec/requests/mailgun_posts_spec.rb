require 'spec_helper'

describe "Mailgun posts", type: :request, fixtures: false do

  describe "POST /emails" do
    let(:params){
      create_incoming_email_params(
        envelope_from: 'bob@bob.com',
        from:          'Bob Smith <bob@bob.com>',
        sender:        'bob@bob.com',
        recipient:     'flying-car@threadable.com',
        to:            'Flying car <flying-car@threadable.com>',
      )
    }
    it "should render succesfully" do
      expect{ post '/emails', params }.to change{ IncomingEmail.count }.by(1)
      expect(response).to be_success
      expect(response.body).to be_blank
      incoming_email = threadable.incoming_emails.all.last
      expect(incoming_email.params).to eq IncomingEmail::Params.load(IncomingEmail::Params.dump(params))
    end

    context 'when the mailgun params are missing' do
      let(:params){ {} }
      it "should render succesfully" do
        expect{ post '/emails', params }.to change{ IncomingEmail.count }.by(0)
        expect(response).to_not be_success
        expect(response.body).to be_blank
      end
    end
  end

end
