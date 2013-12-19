require 'spec_helper'

describe Covered::IncomingEmails do

  let(:incoming_emails){ described_class.new(covered) }
  subject{ incoming_emails }

  let(:scope){ double :scope }
  before do
    IncomingEmail.stub(:all).and_return(scope)
  end

  it { should have_constant :Create }

  let(:incoming_email_record){ double(:incoming_email_record) }
  let(:incoming_email){ double(:incoming_email) }


  describe 'all' do
    it 'returns all incoming emails' do
      all_incoming_emails = [1,2,3]
      expect(scope).to receive(:to_a).and_return(all_incoming_emails)
      expect(Covered::IncomingEmail).to receive(:new).with(covered, 1).and_return(1)
      expect(Covered::IncomingEmail).to receive(:new).with(covered, 2).and_return(2)
      expect(Covered::IncomingEmail).to receive(:new).with(covered, 3).and_return(3)
      expect(incoming_emails.all).to eq [1,2,3]
    end
  end

  describe 'find_by_id' do
    it 'return the incoming_email for the given id' do
      expect(scope).to receive(:where).with(id: 84).and_return(scope)
      expect(scope).to receive(:first).and_return(incoming_email_record)
      expect(Covered::IncomingEmail).to receive(:new).with(covered, incoming_email_record).and_return(incoming_email)
      expect(incoming_emails.find_by_id(84)).to eq incoming_email

      expect(scope).to receive(:where).with(id: 84).and_return(scope)
      expect(scope).to receive(:first).and_return(nil)
      expect(Covered::IncomingEmail).to_not receive(:new)
      expect(incoming_emails.find_by_id(84)).to be_nil
    end
  end

  describe 'find_by_id!' do
    context 'when the incoming_email is found' do
      before{ expect(incoming_emails).to receive(:find_by_id).with(66).and_return(incoming_email) }
      it 'return the incoming_email' do
        expect( incoming_emails.find_by_id!(66) ).to eq incoming_email
      end
    end
    context 'when the incoming_email is not found' do
      before{ expect(incoming_emails).to receive(:find_by_id).with(66).and_return(nil) }
      it 'raises a Covered::RecordNotFound error' do
        expect{ incoming_emails.find_by_id!(66) }.to raise_error(
          Covered::RecordNotFound, 'unable to find incoming email with id 66')
      end
    end
  end

  describe 'create!' do
    it 'calls Create with its self and the given attributes' do
      expect(described_class::Create).to receive(:call).with(incoming_emails, some: 'attributes').and_return(incoming_email)
      expect( incoming_emails.create!(some: 'attributes') ).to eq incoming_email
    end
  end

  its(:inspect){ should == "#<Covered::IncomingEmails>" }

end
