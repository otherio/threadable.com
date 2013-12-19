require 'spec_helper'

describe Covered::CurrentUser do

  let(:user_record){ Factories.create(:user) }
  let(:current_user){ Covered::CurrentUser.new(covered, user_record.id) }
  subject{ current_user }

  its(:to_param     ){ should eq user_record.to_param     }
  its(:name         ){ should eq user_record.name         }
  its(:slug         ){ should eq user_record.slug         }
  its(:new_record?  ){ should eq user_record.new_record?  }
  its(:persisted?   ){ should eq user_record.persisted?   }
  its(:avatar_url   ){ should eq user_record.avatar_url   }

  its(:inspect){ should eq %(#<Covered::CurrentUser id: #{user_record.id}, email_address: #{user_record.email_address.inspect}, slug: #{user_record.slug.inspect}>) }

  its(:errors){ should be_a user_record.errors.class }

  its(:as_json){
    should eq(
      id:            subject.id,
      param:         subject.to_param,
      name:          subject.name,
      email_address: subject.email_address,
      slug:          subject.slug,
      avatar_url:    subject.avatar_url,
    )
  }

  its(:projects){ should be_a Covered::User::Projects }

  describe "==" do
    it "should match on user_id" do
      expect(current_user).to eq Covered::CurrentUser.new(covered, user_record.id)
    end
  end

  describe 'confirm!' do
    it "should confirm the user" do
      expect(user_record).to_not be_confirmed
      current_user.confirm!
      user_record.reload
      expect(user_record).to be_confirmed
    end
  end

  describe '#update' do
    it "should update the user record" do
      expect(current_user.update(name: 'Steve Busheby')).to be_true
      user_record.reload
      expect(user_record.name).to eq 'Steve Busheby'
    end
  end


end
