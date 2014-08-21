require 'spec_helper'

describe Threadable::CurrentUser, :type => :model do

  let(:user_record){ Factories.create(:user) }
  let(:current_user){ described_class.new(threadable, user_record.id) }
  subject{ current_user }

  describe '#to_param' do
    subject { super().to_param }
    it { is_expected.to eq user_record.to_param     }
  end

  describe '#name' do
    subject { super().name }
    it { is_expected.to eq user_record.name         }
  end

  describe '#slug' do
    subject { super().slug }
    it { is_expected.to eq user_record.slug         }
  end

  describe '#new_record?' do
    subject { super().new_record? }
    it { is_expected.to eq user_record.new_record?  }
  end

  describe '#persisted?' do
    subject { super().persisted? }
    it { is_expected.to eq user_record.persisted?   }
  end

  describe '#avatar_url' do
    subject { super().avatar_url }
    it { is_expected.to eq user_record.avatar_url   }
  end

  describe '#inspect' do
    subject { super().inspect }
    it {
    is_expected.to eq(
      %(#<Threadable::CurrentUser id: #{user_record.id}, email_address: #{user_record.email_address.to_s.inspect}, slug: #{user_record.slug.inspect}>)
    )
  }
  end

  describe '#errors' do
    subject { super().errors }
    it { is_expected.to be_a user_record.errors.class }
  end

  describe '#as_json' do
    subject { super().as_json }
    it {
    is_expected.to eq(
      id:            current_user.id,
      param:         current_user.to_param,
      name:          current_user.name,
      email_address: current_user.email_address.to_s,
      slug:          current_user.slug,
      avatar_url:    current_user.avatar_url,
    )
  }
  end

  describe '#organizations' do
    subject { super().organizations }
    it { is_expected.to be_a Threadable::User::Organizations }
  end

  describe "==" do
    it "should match on user_id" do
      expect(current_user).to eq Threadable::CurrentUser.new(threadable, user_record.id)
    end
  end

  describe '#update' do
    it "should update the user record" do
      expect(current_user.update(name: 'Steve Busheby')).to be_truthy
      user_record.reload
      expect(user_record.name).to eq 'Steve Busheby'
    end
  end

  describe 'regenerate_api_access_token!' do
    it 'should deactivate any existing tokens and generate a new one' do
      expect(ApiAccessToken.all).to match_array []
      expect(current_user.api_access_token).to be_nil

      token1 = current_user.regenerate_api_access_token!
      expect(ApiAccessToken.all).to match_array [token1]
      expect(token1).to be_a ApiAccessToken
      expect(token1).to be_active
      expect(token1.user_id).to be current_user.id
      expect(current_user.api_access_token).to eq token1


      token2 = current_user.regenerate_api_access_token!
      expect(ApiAccessToken.all).to match_array [token1, token2]
      expect(current_user.api_access_token).to eq token2

      token1.reload
      expect(token1).to_not be_active
      expect(token2).to be_active
      expect(token1).to_not eq(token2)
    end
  end

end
