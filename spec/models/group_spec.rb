require 'spec_helper'

describe Group do


  describe 'validations' do
    it "requires a name" do
      group = Group.new(organization_id: 1, subject_tag: '')
      group.save.should be_false
      group.errors[:name].should =~ ["can't be blank", "is invalid"]

      group.name = 'electronics'
      group.save.should be_true
      group.errors.should be_blank
    end

    it "requires an organization" do
      group = Group.new(name: 'foo', subject_tag: '')
      group.save.should be_false
      group.errors[:organization_id].should == ["can't be blank"]

      group.organization_id = 1
      group.save.should be_true
      group.errors.should be_blank
    end

    it "requires a unique name, scoped to the organization" do
      group = Group.new(name: 'hi there', organization_id: 1, subject_tag: '')
      group.save.should be_true

      group = Group.new(name: 'hi there', organization_id: 2, subject_tag: '')
      group.save.should be_true

      group = Group.new(name: 'hi there', organization_id: 1, subject_tag: '')
      group.save.should be_false
      group.errors[:name].should == ["has already been taken"]
    end

    it "requires a unique email_address_tag, scoped to the organization" do
      group = Group.new(name: 'hi there', organization_id: 1, subject_tag: '')
      group.save.should be_true

      group = Group.new(name: 'hi there', organization_id: 2, subject_tag: '')
      group.save.should be_true

      group = Group.new(name: 'hi-there', organization_id: 1, subject_tag: '')
      group.save.should be_false
      group.errors[:email_address_tag].should == ["has already been taken"]
    end

    it "requires the name to not contain special characters" do
      group = Group.new(name: 'Foo+3', organization_id: 1, subject_tag: '')
      group.save.should be_false
      group.errors[:name].should == ['is invalid']

      group.name = 'F-o-o'
      group.save.should be_true
      group.errors.should be_blank
    end

    it "requires the subject tag to not contain special characters" do
      group = Group.new(name: 'Foo', organization_id: 1, subject_tag: 'Foo%#$')
      group.save.should be_false
      group.errors[:subject_tag].should == ['is invalid']

      group.subject_tag = 'F-o+o'
      group.save.should be_true
      group.errors.should be_blank
    end

    it "does not create a group with a email_address_tag of 'task' or 'everyone'" do
      group = Group.new(name: 'Task', organization_id: 1, subject_tag: '')
      group.save.should be_false
      group.errors[:email_address_tag].should == ['is reserved']

      group.name = 'Everyone'
      group.save.should be_false
      group.errors[:email_address_tag].should == ['is reserved']
    end

    it "prohibits +  and -- in the email address tag" do
      group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', email_address_tag: 'foo+bar')
      group.save.should be_false
      group.errors[:email_address_tag].should == ['is invalid']

      group.email_address_tag = 'foo--bar'
      group.save.should be_false
      group.errors[:email_address_tag].should == ['is invalid']
    end
  end

  describe "#name=" do
    it "creates a new email_address_tag if the email_address_tag is blank" do
      group = Group.create(name: 'fall down a hole', organization_id: 1)
      group.save.should be_true
      group.email_address_tag.should == 'fall-down-a-hole'
    end

    it "generates lowercase email_address_tags from uppercase names" do
      group = Group.create(name: 'Fall Down a Hole', organization_id: 1)
      group.save.should be_true
      group.email_address_tag.should == 'fall-down-a-hole'
    end

    it "does not reset the email_address_tag when the group is renamed" do
      group = Group.create(name: 'Fall Down a Hole', organization_id: 1)
      group.save.should be_true
      group.email_address_tag.should == 'fall-down-a-hole'

      group.name = 'foo bar'
      group.save.should be_true
      group.email_address_tag.should == 'fall-down-a-hole'
    end
  end
end
