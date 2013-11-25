require 'spec_helper'

describe Covered::CurrentUser::Project do

  let(:user_record   ){ Factories.create(:user) }
  let(:project_record){ Factories.create(:project, name: 'Flying cow') }
  before{ project_record.members << user_record if project_record.persisted? }
  let(:current_user) { Covered::CurrentUser.new(covered, user_record.id) }
  let(:project){ described_class.new(current_user, project_record) }
  subject{ project }

  its(:covered      ){ should == covered                    }
  its(:current_user ){ should == current_user               }
  its(:id           ){ should == project_record.id          }
  its(:to_param     ){ should == project_record.to_param    }
  its(:name         ){ should == project_record.name        }
  its(:short_name   ){ should == project_record.short_name  }
  its(:slug         ){ should == project_record.slug        }
  its(:subject_tag  ){ should == project_record.subject_tag }
  its(:description  ){ should == project_record.description }
  # its(:errors       ){ should == project_record.errors      }
  its(:new_record?  ){ should == project_record.new_record? }
  its(:persisted?   ){ should == project_record.persisted?  }

  describe ".model_name" do
    subject{ described_class.model_name }
    it { should == ::Project.model_name }
  end

  describe "#to_key" do
    subject{ project.to_key }
    context "when the project record's id is nil" do
      let(:project){ current_user.projects.new }
      it { should be_nil }
    end
    context "when the project record's id is not nil" do
      it { should eq [project_record.id] }
    end
  end

  its(:email_address){ should eq "#{project_record.email_address_username}@#{covered.email_host}" }
  its(:formatted_email_address){ should eq "#{project_record.name} <#{project_record.email_address_username}@#{covered.email_host}>" }
  its(:list_id){ should eq "#{project_record.email_address_username}.#{covered.email_host}" }
  its(:formatted_list_id){ "#{project_record.name} <#{project_record.email_address_username}.#{covered.email_host}>" }


  its(:members      ){ should be_a Covered::CurrentUser::Project::Members       }
  its(:conversations){ should be_a Covered::CurrentUser::Project::Conversations }
  # its(:messages     ){ should be_a Covered::CurrentUser::Project::Messages      }
  its(:tasks        ){ should be_a Covered::CurrentUser::Project::Tasks         }

  describe '#update' do
    it "should update the user record" do
      expect(project.update(name: 'Flying duck')).to be_true
      project_record.reload
      expect(project_record.name).to eq 'Flying duck'
    end
  end

  describe '#leave!' do
    it "should remove the current member from the project" do
      expect(project_record.members).to include user_record
      project.leave!
      project_record.reload
      expect(project_record.members).to_not include user_record
    end
  end


  its(:inspect){ should eq %(#<Covered::CurrentUser::Project project_id: #{project_record.id}, name: "Flying cow">) }
  its(:as_json){ should eq(
    id:          project.id,
    param:       project.to_param,
    name:        project.name,
    short_name:  project.short_name,
    slug:        project.slug,
    subject_tag: project.subject_tag,
    description: project.description,
  )}

  describe '#==' do
    it "should judge equality based on id" do
      expect(project).to eq Covered::CurrentUser::Project.new(current_user, Project.new(id: project_record.id))
    end
  end

end
