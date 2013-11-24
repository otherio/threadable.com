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

  its(:inspect       ){ should eq %(#<Covered::User id: #{user_record.id}>) }

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


end
