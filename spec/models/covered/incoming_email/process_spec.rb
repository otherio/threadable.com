require 'spec_helper'

describe Covered::IncomingEmail::Process do



  let :incoming_email do
    double(:incoming_email,
      id: 9931,
      covered: double(:covered),
    )
  end

  def call!
    described_class.call(incoming_email)
  end

  context 'when the incoming email has already been processed' do
    before{ incoming_email.stub :processed? => true }
    it 'raises an ArgumentError' do
      expect{ call! }.to raise_error(ArgumentError, 'IncomingEmail 9931 has already been processed')
    end
  end

  context 'when the incoming email has not been processed' do
    before do
      incoming_email.stub :processed? => false
      expect(Covered).to receive(:transaction).and_yield
      expect(incoming_email).to receive(:find_organization!)
      expect(incoming_email).to receive(:find_groups!)
    end
    context 'and the organization or groups are not found' do
      before do
        expect(incoming_email).to receive(:bounceable?).and_return(true)
      end
      it 'bounces the incoming email' do
        expect(incoming_email).to receive(:bounce!)
        expect(incoming_email).to receive(:processed!)
        call!
      end
    end
    context 'and the organization and groups are found' do
      before do
        expect(incoming_email).to receive(:bounceable?).once.and_return(false)
        expect(incoming_email).to receive(:find_message!)
        expect(incoming_email).to receive(:find_creator!)
        expect(incoming_email).to receive(:find_parent_message!)
        expect(incoming_email).to receive(:find_conversation!)
      end
      context 'and the incoming_email is deliverable' do
        before do
          expect(incoming_email).to receive(:deliverable?).once.and_return(true)
          expect(incoming_email).to receive(:deliver!)
          expect(incoming_email).to receive(:processed!)
        end
        context 'and the creator is found' do
          before{ expect(incoming_email).to receive(:creator).and_return(double(:creator, id: 94)) }
          it 'signs in as the creator' do
            expect(incoming_email.covered).to receive(:current_user_id=).with(94)
            call!
          end
        end
        context 'and the creator is not found' do
          before{ expect(incoming_email).to receive(:creator).and_return(nil) }
          it 'signs out' do
            expect(incoming_email.covered).to receive(:current_user_id=).with(nil)
            call!
          end
        end
      end
      context 'and the incoming_email is not deliverable' do
        before do
          expect(incoming_email).to receive(:deliverable?).once.and_return(false)
          expect(incoming_email).to receive(:creator).and_return(double(:creator, id: 94))
          expect(incoming_email.covered).to receive(:current_user_id=).with(94)
        end
        context 'and the incoming_email is holdable' do
          before{ expect(incoming_email).to receive(:holdable?).once.and_return(true) }
          it 'holds the incoming email' do
            expect(incoming_email).to receive(:hold!)
            expect(incoming_email).to receive(:processed!)
            call!
          end
        end
        context 'and the incoming_email is not holdable' do
          before{ expect(incoming_email).to receive(:holdable?).once.and_return(false) }
          it 'bounces the incoming email' do
            expect(incoming_email).to receive(:bounce!)
            expect(incoming_email).to receive(:processed!)
            call!
          end
        end
      end
    end
  end

end
