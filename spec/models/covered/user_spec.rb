require 'spec_helper'

describe Covered::User do

  let(:user_record){ Factories.create(:user) }

  let(:user){ described_class.new(covered, user_record) }
  subject{ user }

  its(:covered       ){ should eq covered                   }
  its(:user_record   ){ should eq user_record               }
  its(:id            ){ should eq user_record.id            }
  its(:user_id       ){ should eq user_record.id            }
  its(:to_param      ){ should eq user_record.to_param      }
  its(:name          ){ should eq user_record.name          }
  its(:email_address ){ should eq user_record.email_address }
  its(:slug          ){ should eq user_record.slug          }
  its(:errors        ){ should eq user_record.errors        }
  its(:new_record?   ){ should eq user_record.new_record?   }
  its(:persisted?    ){ should eq user_record.persisted?    }
  its(:avatar_url    ){ should eq user_record.avatar_url    }

  its(:inspect       ){ should eq %(#<Covered::User user_id: #{user_record.id}>) }

  %w{
    id
    to_param
    name
    email_address
    slug
    errors
    new_record?
    persisted?
    avatar_url
    authenticate
    created_at
  }.each do |method|
    describe "##{method}" do
      specify{ expect(user).to delegate(method).to(:user_record) }
    end
  end

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
    email_address: user.email_address,
    slug:          user.slug,
    avatar_url:    user.avatar_url,
  )}

  it { should eq described_class.new(covered, user_record) }

  describe 'update' do
    it 'updates mixpanel' do
      expect(user).to receive(:update_mixpanel)
      user.update(name: 'A. Person')
    end
  end

  describe 'update_mixpanel' do
    it 'sends the name and email to mixpanel' do
      expect(covered.tracker.people).to receive(:set).with(user.id, {
        '$name'        => user.name,
        '$email'       => user.email_address,
        '$created'     => user.created_at.iso8601,
      })
      user.update_mixpanel
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

  describe 'confirm!' do
    it 'should update the confirmed_at field with the current time'
  end

end
