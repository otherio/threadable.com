require 'spec_helper'

describe Threadable::User do

  let(:user_record){ Factories.create(:user) }

  let(:user){ described_class.new(threadable, user_record) }
  subject{ user }

  it { should have_constant :EmailAddresses }
  it { should have_constant :EmailAddress }
  it { should have_constant :Organizations }
  it { should have_constant :Messages }

  its(:threadable    ){ should eq threadable                }
  its(:user_record   ){ should eq user_record               }
  its(:id            ){ should eq user_record.id            }
  its(:user_id       ){ should eq user_record.id            }
  its(:to_param      ){ should eq user_record.to_param      }
  its(:name          ){ should eq user_record.name          }
  its(:email_address ){ should eq user_record.primary_email_address.address }
  its(:slug          ){ should eq user_record.slug          }
  its(:errors        ){ should eq user_record.errors        }
  its(:new_record?   ){ should eq user_record.new_record?   }
  its(:persisted?    ){ should eq user_record.persisted?    }
  its(:avatar_url    ){ should eq user_record.avatar_url    }

  its(:inspect       ){ should eq %(#<Threadable::User id: #{user_record.id}, email_address: #{user_record.email_address.inspect}, slug: #{user_record.slug.inspect}>) }

  it { should delegate(:id           ).to(:user_record) }
  it { should delegate(:to_param     ).to(:user_record) }
  it { should delegate(:name         ).to(:user_record) }
  it { should delegate(:slug         ).to(:user_record) }
  it { should delegate(:errors       ).to(:user_record) }
  it { should delegate(:new_record?  ).to(:user_record) }
  it { should delegate(:persisted?   ).to(:user_record) }
  it { should delegate(:avatar_url   ).to(:user_record) }
  it { should delegate(:authenticate ).to(:user_record) }
  it { should delegate(:created_at   ).to(:user_record) }

  describe "to_key" do
    subject{ user.to_key }
    context "when the user record's id is nil" do
      let(:user_record){ User.new }
      it { should be_nil }
    end
    context "when the user record's id is not nil" do
      it { should eq [user_record.id] }
    end
  end

  its(:as_json){ should eq(
    id:            user.id,
    param:         user.to_param,
    name:          user.name,
    email_address: user.email_address.to_s,
    slug:          user.slug,
    avatar_url:    user.avatar_url,
  )}

  it { should eq described_class.new(threadable, user_record) }

  describe 'update' do
    it 'updates mixpanel' do
      expect(user).to receive(:track_update!)
      user.update(name: 'A. Person')
    end
  end

  describe 'track_update!' do
    it 'sends the name and email to mixpanel' do
      expect(threadable.tracker).to receive(:track_user_change).with(user)
      user.track_update!
    end
  end

  describe 'web_enabled?' do
    it 'should return the presense of a password' do
      user_record.stub encrypted_password: 'FSDFDSFDSFDS'
      expect(user).to be_web_enabled
      user_record.stub encrypted_password: nil
      expect(user).to_not be_web_enabled
    end
  end

  describe 'requires_setup?' do
    it 'should return the the oposite of requires_setup?' do
      user.stub web_enabled?: false
      expect(user.requires_setup?).to be_true
      user.stub web_enabled?: true
      expect(user.requires_setup?).to be_false
    end
  end

end
