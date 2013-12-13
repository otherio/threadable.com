require 'spec_helper'

describe EmailsController do

  let(:params){ create_incoming_email_params }

  describe "POST create" do

    context "when the post data has a valid signature" do
      it "should render succesfully" do
        expect(covered.incoming_emails).to receive(:create!).with(params)
        expect(covered).to_not receive(:track)
        post :create, params
        expect(response).to be_success
        expect(response.body).to be_blank
      end
    end

    context "when the post data does not have a valid signature" do
      before{ params[:signature] = 'badsignature' }
      it "should not render succesfully" do
        expect(covered.incoming_emails).to_not receive(:create!)
        expect(covered).to_not receive(:track)
        post :create, params
        expect(response).to_not be_success
        expect(response.body).to be_blank
      end
    end

    context 'when the message is invalid' do
      it "renders a 406" do
        error = Covered::RejectedIncomingEmail.new('cannot start conversation. sender is not a member of the project')
        expect(covered.incoming_emails).to receive(:create!).and_raise(error)
        expect(covered).to receive(:track).with("Exception",
          'Class'           => 'Covered::RejectedIncomingEmail',
          'message'         => 'cannot start conversation. sender is not a member of the project',
          'Sender'          => params['Sender'],
          'X-Envelope-From' => params['X-Envelope-From'],
          'From'            => params['From'],
          'recipient'       => params['recipient'],
          'To'              => params['To'],
          'Cc'              => params['Cc'],
          'Subject'         => params['Subject'],
          'Date'            => params['Date'],
          'In-Reply-To'     => params['In-Reply-To'],
          'References'      => params['References'],
          'Message-Id'      => params['Message-Id'],
          'Content-Type'    => params['Content-Type'],
        )
        post :create, params
        expect(response.status).to eq 406
        expect(response.body).to be_blank
      end
    end

    context 'when we cannot save the incoming email' do
      it 'renders a 500' do
        expect(covered.incoming_emails).to receive(:create!).and_raise(Covered::RecordInvalid)
        post :create, params
        expect(response.status).to eq 500
        expect(response.body).to be_blank
      end
    end

  end

end
