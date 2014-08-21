require 'spec_helper'

describe Threadable::Class, :type => :model do

  let(:user_record){ Factories.create(:user) }
  let(:host) { 'example.com' }
  subject(:threadable){ Threadable.new(host: host, port: 3000, current_user_id: user_record.id) }

  describe "new" do
    it "should require host and optionally take port and current_user_id" do
      expect{ Threadable.new                                                                  }.to     raise_error ArgumentError
      expect{ Threadable.new host: 'example.com'                                              }.to_not raise_error
      expect{ Threadable.new host: 'example.com', port: 3000                                  }.to_not raise_error
      expect{ Threadable.new host: 'example.com', port: 3000, current_user_id: user_record.id }.to_not raise_error
      expect{ Threadable.new host: 'example.com', port: 3000, current_user_id: user_record.id, protocol: 'https' }.to_not raise_error
    end
  end

  describe '#protocol' do
    subject { super().protocol }
    it { is_expected.to eq 'http'  }
  end

  describe '#host' do
    subject { super().host }
    it { is_expected.to eq 'example.com'  }
  end

  describe '#port' do
    subject { super().port }
    it { is_expected.to eq 3000           }
  end

  describe '#current_user_id' do
    subject { super().current_user_id }
    it { is_expected.to eq user_record.id }
  end

  describe '#emails' do
    subject { super().emails }
    it { is_expected.to be_a Threadable::Emails         }
  end

  describe '#users' do
    subject { super().users }
    it { is_expected.to be_a Threadable::Users          }
  end

  describe '#organizations' do
    subject { super().organizations }
    it { is_expected.to be_a Threadable::Organizations  }
  end

  describe '#conversations' do
    subject { super().conversations }
    it { is_expected.to be_a Threadable::Conversations  }
  end

  describe '#tasks' do
    subject { super().tasks }
    it { is_expected.to be_a Threadable::Tasks          }
  end

  describe '#messages' do
    subject { super().messages }
    it { is_expected.to be_a Threadable::Messages       }
  end

  describe '#attachments' do
    subject { super().attachments }
    it { is_expected.to be_a Threadable::Attachments    }
  end

  describe '#incoming_emails' do
    subject { super().incoming_emails }
    it { is_expected.to be_a Threadable::IncomingEmails }
  end

  describe '#events' do
    subject { super().events }
    it { is_expected.to be_a Threadable::Events         }
  end

  describe '#groups' do
    subject { super().groups }
    it { is_expected.to be_a Threadable::Groups         }
  end


  describe '#env' do
    subject { super().env }
    it { is_expected.to eq(
    "protocol" => 'http',
    "host" => 'example.com',
    "port" => 3000,
    "current_user_id" => user_record.id,
    "worker" => false,
  )}
  end

  it { is_expected.to delegate(:track).to(:tracker) }

  describe "#==" do
    it "should be equal if the other object is an instance of Threadable and the env hashes are equal" do
      expect( threadable ).to     eq Threadable.new(threadable.env)
      expect( threadable ).to_not eq Threadable.new(threadable.env.merge(port: 34543))
    end
  end

  it "should work" do
    expect(threadable.organizations.new).to be_a Threadable::Organization
    expect(threadable.users.new   ).to be_a Threadable::User

    expect(threadable.organizations.new.threadable).to eq threadable
    expect(threadable.users.new.threadable   ).to eq threadable
  end

  describe 'email_host' do
    before do
      stub_const('Threadable::Class::EMAIL_HOSTS', {'example.com' => 'mail.example.com'})
    end

    context 'when the host has an email host associated' do
      it 'returns the email host' do
        expect(threadable.email_host).to eq 'mail.example.com'
      end
    end

    context 'when no email host is present' do
      let(:host) { 'notpresent.example.com' }
      it 'returns the web host' do
        expect(threadable.email_host).to eq 'notpresent.example.com'
      end
    end
  end

  describe '#email_hosts' do
    before do
      stub_const('Threadable::Class::EMAIL_HOSTS', {'example.com' => 'mail.example.com', 'foo.com' => 'foo.com'})
    end

    it 'returns the valid basic email hosts' do
      expect(threadable.email_hosts).to match_array ['mail.example.com', 'foo.com']
    end
  end

  describe '#support_email_address' do
    it "returns a support email address" do
      expect( threadable.support_email_address ).to eq 'support@example.com'
    end

    it 'returns an email address with an optional tag' do
      expect( threadable.support_email_address('foo-bar') ).to eq 'support+foo-bar@example.com'
    end
  end

end
