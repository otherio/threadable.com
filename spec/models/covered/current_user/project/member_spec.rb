require 'spec_helper'

describe Covered::CurrentUser::Project::Member do

  let(:covered_current_user_record){ Factories.create(:user) }
  let(:user_record){ Factories.create(:user) }
  let(:project_record){ Factories.create(:project) }
  let(:project_membership_record){ project_record.memberships.create!(user: user_record) }
  before{ project_record.members << covered_current_user_record }
  let(:project){ Covered::CurrentUser::Project.new(current_user, project_record) }
  let(:member){ Covered::CurrentUser::Project::Member.new(project, project_membership_record) }

  subject{ member }

  it{ should eq Covered::CurrentUser::Project::Member.new(project, project_membership_record) }
  its(:covered        ){ should eq covered }
  its(:project        ){ should eq project }
  its(:user_record    ){ should eq user_record }
  its(:project_record ){ should eq project_record }
  its(:id             ){ should eq user_record.id }
  its(:name           ){ should eq user_record.name }
  its(:email_address  ){ should eq user_record.email_address }
  its(:subscribed?    ){ should eq project_membership_record.subscribed? }

  its(:user){ should be_a Covered::User }
  its(:user){ should eq Covered::User.new(covered, user_record) }

  its(:inspect){ should eq(
    %(#<Covered::CurrentUser::Project::Member project_id: #{project_record.id.inspect}, user_id: #{user_record.id.inspect}>)
  )}

end
