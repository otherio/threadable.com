require 'spec_helper'

describe Threadable::User, :type => :model do

  let(:user_record){ Factories.create(:user) }

  let(:user){ described_class.new(threadable, user_record) }
  subject{ user }

  it { is_expected.to have_constant :EmailAddresses }
  it { is_expected.to have_constant :EmailAddress }
  it { is_expected.to have_constant :Organizations }
  it { is_expected.to have_constant :Organization }
  it { is_expected.to have_constant :Messages }

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq threadable                   }
  end

  describe '#user_record' do
    subject { super().user_record }
    it { is_expected.to eq user_record               }
  end

  describe '#id' do
    subject { super().id }
    it { is_expected.to eq user_record.id            }
  end

  describe '#user_id' do
    subject { super().user_id }
    it { is_expected.to eq user_record.id            }
  end

  describe '#to_param' do
    subject { super().to_param }
    it { is_expected.to eq user_record.to_param      }
  end

  describe '#name' do
    subject { super().name }
    it { is_expected.to eq user_record.name          }
  end

  describe '#email_address' do
    subject { super().email_address }
    it { is_expected.to eq user_record.primary_email_address.address }
  end

  describe '#slug' do
    subject { super().slug }
    it { is_expected.to eq user_record.slug          }
  end

  describe '#errors' do
    subject { super().errors }
    it { is_expected.to eq user_record.errors        }
  end

  describe '#new_record?' do
    subject { super().new_record? }
    it { is_expected.to eq user_record.new_record?   }
  end

  describe '#persisted?' do
    subject { super().persisted? }
    it { is_expected.to eq user_record.persisted?    }
  end

  describe '#avatar_url' do
    subject { super().avatar_url }
    it { is_expected.to eq user_record.avatar_url    }
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq %(#<Threadable::User id: #{user_record.id}, email_address: #{user_record.email_address.inspect}, slug: #{user_record.slug.inspect}>) }
  end

  it { is_expected.to delegate(:id           ).to(:user_record) }
  it { is_expected.to delegate(:to_param     ).to(:user_record) }
  it { is_expected.to delegate(:name         ).to(:user_record) }
  it { is_expected.to delegate(:slug         ).to(:user_record) }
  it { is_expected.to delegate(:errors       ).to(:user_record) }
  it { is_expected.to delegate(:new_record?  ).to(:user_record) }
  it { is_expected.to delegate(:persisted?   ).to(:user_record) }
  it { is_expected.to delegate(:avatar_url   ).to(:user_record) }
  it { is_expected.to delegate(:authenticate ).to(:user_record) }
  it { is_expected.to delegate(:created_at   ).to(:user_record) }

  describe "to_key" do
    subject{ user.to_key }
    context "when the user record's id is nil" do
      let(:user_record){ User.new }
      it { is_expected.to be_nil }
    end
    context "when the user record's id is not nil" do
      it { is_expected.to eq [user_record.id] }
    end
  end

  describe '#as_json' do
    subject { super().as_json }
    it { is_expected.to eq(
    id:            user.id,
    param:         user.to_param,
    name:          user.name,
    email_address: user.email_address.to_s,
    slug:          user.slug,
    avatar_url:    user.avatar_url,
  )}
  end

  it { is_expected.to eq described_class.new(threadable, user_record) }

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
      expect(user.requires_setup?).to be_truthy
      user.stub web_enabled?: true
      expect(user.requires_setup?).to be_falsey
    end
  end

end
