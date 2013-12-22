require 'spec_helper'

describe Covered::Class do

  let(:user_record){ Factories.create(:user) }
  let(:host) { 'example.com' }
  subject(:covered){ Covered.new(host: host, port: 3000, current_user_id: user_record.id) }

  describe "new" do
    it "should require host and optionally take port and current_user_id" do
      expect{ Covered.new                                                                  }.to     raise_error ArgumentError
      expect{ Covered.new host: 'example.com'                                              }.to_not raise_error
      expect{ Covered.new host: 'example.com', port: 3000                                  }.to_not raise_error
      expect{ Covered.new host: 'example.com', port: 3000, current_user_id: user_record.id }.to_not raise_error
      expect{ Covered.new host: 'example.com', port: 3000, current_user_id: user_record.id, protocol: 'https' }.to_not raise_error
    end
  end

  its(:protocol        ){ should eq 'http'  }
  its(:host            ){ should eq 'example.com'  }
  its(:port            ){ should eq 3000           }
  its(:current_user_id ){ should eq user_record.id }

  its(:emails          ){ should be_a Covered::Emails         }
  its(:users           ){ should be_a Covered::Users          }
  its(:projects        ){ should be_a Covered::Projects       }
  its(:conversations   ){ should be_a Covered::Conversations  }
  its(:tasks           ){ should be_a Covered::Tasks          }
  its(:messages        ){ should be_a Covered::Messages       }
  its(:attachments     ){ should be_a Covered::Attachments    }
  its(:incoming_emails ){ should be_a Covered::IncomingEmails }


  its(:env             ){ should eq(
    "protocol" => 'http',
    "host" => 'example.com',
    "port" => 3000,
    "current_user_id" => user_record.id,
    "worker" => false,
  )}

  it { should delegate(:track).to(:tracker) }

  describe "#==" do
    it "should be equal if the other object is an instance of Covered and the env hashes are equal" do
      expect( covered ).to     eq Covered.new(covered.env)
      expect( covered ).to_not eq Covered.new(covered.env.merge(port: 34543))
    end
  end

  it "should work" do
    expect(covered.projects.new).to be_a Covered::Project
    expect(covered.users.new   ).to be_a Covered::User

    expect(covered.projects.new.covered).to eq covered
    expect(covered.users.new.covered   ).to eq covered
  end

  describe 'email_host' do
    before do
      stub_const('Covered::Class::EMAIL_HOSTS', {'example.com' => 'mail.example.com'})
    end

    context 'when the host has an email host associated' do
      it 'returns the email host' do
        expect(covered.email_host).to eq 'mail.example.com'
      end
    end

    context 'when no email host is present' do
      let(:host) { 'notpresent.example.com' }
      it 'returns the web host' do
        expect(covered.email_host).to eq 'notpresent.example.com'
      end
    end
  end

  describe '#support_email_address' do
    it "returns a support email address" do
      expect( covered.support_email_address ).to eq 'support@example.com'
    end

    it 'returns an email address with an optional tag' do
      expect( covered.support_email_address('foo-bar') ).to eq 'support+foo-bar@example.com'
    end
  end

end
