require 'spec_helper'

describe Threadable::Class do

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

  its(:protocol        ){ should eq 'http'  }
  its(:host            ){ should eq 'example.com'  }
  its(:port            ){ should eq 3000           }
  its(:current_user_id ){ should eq user_record.id }

  its(:emails          ){ should be_a Threadable::Emails         }
  its(:users           ){ should be_a Threadable::Users          }
  its(:organizations   ){ should be_a Threadable::Organizations  }
  its(:conversations   ){ should be_a Threadable::Conversations  }
  its(:tasks           ){ should be_a Threadable::Tasks          }
  its(:messages        ){ should be_a Threadable::Messages       }
  its(:attachments     ){ should be_a Threadable::Attachments    }
  its(:incoming_emails ){ should be_a Threadable::IncomingEmails }
  its(:events          ){ should be_a Threadable::Events         }
  its(:groups          ){ should be_a Threadable::Groups         }


  its(:env             ){ should eq(
    "protocol" => 'http',
    "host" => 'example.com',
    "port" => 3000,
    "current_user_id" => user_record.id,
    "worker" => false,
  )}

  it { should delegate(:track).to(:tracker) }

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

  describe '#support_email_address' do
    it "returns a support email address" do
      expect( threadable.support_email_address ).to eq 'support@example.com'
    end

    it 'returns an email address with an optional tag' do
      expect( threadable.support_email_address('foo-bar') ).to eq 'support+foo-bar@example.com'
    end
  end

end
