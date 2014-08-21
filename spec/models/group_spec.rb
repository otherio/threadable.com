require 'spec_helper'

describe Group, :type => :model do


  describe 'validations' do
    it "requires a name" do
      group = Group.new(organization_id: 1, subject_tag: '')
      expect(group.save).to be_falsey
      expect(group.errors[:name]).to match_array(["can't be blank"])

      group.name = 'electronics'
      expect(group.save).to be_truthy
      expect(group.errors).to be_blank
    end

    it "requires an organization" do
      group = Group.new(name: 'foo', subject_tag: '')
      expect(group.save).to be_falsey
      expect(group.errors[:organization_id]).to eq(["can't be blank"])

      group.organization_id = 1
      expect(group.save).to be_truthy
      expect(group.errors).to be_blank
    end

    it "requires a unique name, scoped to the organization" do
      group = Group.new(name: 'hi there', organization_id: 1, subject_tag: '')
      expect(group.save).to be_truthy

      group = Group.new(name: 'hi there', organization_id: 2, subject_tag: '')
      expect(group.save).to be_truthy

      group = Group.new(name: 'hi there', organization_id: 1, subject_tag: '')
      expect(group.save).to be_falsey
      expect(group.errors[:name]).to eq(["has already been taken"])
    end

    it "requires a unique email_address_tag, scoped to the organization" do
      group = Group.new(name: 'hi there', organization_id: 1, subject_tag: '')
      expect(group.save).to be_truthy

      group = Group.new(name: 'hi there', organization_id: 2, subject_tag: '')
      expect(group.save).to be_truthy

      group = Group.new(name: 'hi-there', organization_id: 1, subject_tag: '')
      expect(group.save).to be_falsey
      expect(group.errors[:email_address_tag]).to eq(["has already been taken"])
    end

    it "requires the subject tag to not contain special characters" do
      group = Group.new(name: 'Foo', organization_id: 1, subject_tag: 'Foo%#$')
      expect(group.save).to be_falsey
      expect(group.errors[:subject_tag]).to eq(['is invalid'])

      group.subject_tag = 'F-o+o'
      expect(group.save).to be_truthy
      expect(group.errors).to be_blank
    end

    it "does not create a group with a email_address_tag of 'task' or 'everyone'" do
      group = Group.new(name: 'Task', organization_id: 1, subject_tag: '')
      expect(group.save).to be_falsey
      expect(group.errors[:email_address_tag]).to eq(['is reserved'])

      group.name = 'Everyone'
      expect(group.save).to be_falsey
      expect(group.errors[:email_address_tag]).to eq(['is reserved'])
    end

    it "prohibits +  and -- in the email address tag" do
      group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', email_address_tag: 'foo+bar')
      expect(group.save).to be_falsey
      expect(group.errors[:email_address_tag]).to eq(['is invalid'])

      group.email_address_tag = 'foo--bar'
      expect(group.save).to be_falsey
      expect(group.errors[:email_address_tag]).to eq(['is invalid'])
    end

    it "only allows valid webhook urls" do
      group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', webhook_url: 'your mom')
      expect(group.save).to be_falsey
      expect(group.errors[:webhook_url]).to eq(["is not a invalid url"])

      group.webhook_url = 'ftp://foo.com'
      expect(group.save).to be_falsey
      expect(group.errors[:webhook_url]).to eq(['must start with either http or https'])

      group.webhook_url = 'http://foo'
      expect(group.save).to be_falsey
      expect(group.errors[:webhook_url]).to eq(['does not have a valid host'])
    end

    it "allows a blank webhook url" do
      group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', webhook_url: '')
      expect(group.save).to be_truthy
    end

    it "allows a valid webhook url" do
      group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', webhook_url: 'https://foo.com')
      expect(group.save).to be_truthy
    end

    describe 'alias_email_address' do
      it 'allows a plain email address' do
        group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', alias_email_address: 'foo@example.com')
        expect(group.save).to be_truthy
      end

      it 'allows a formatted email address' do
        group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', alias_email_address: '"Foo" <foo@example.com>')
        expect(group.save).to be_truthy
      end

      it 'allows a blank email address' do
        group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', alias_email_address: '')
        expect(group.save).to be_truthy
      end

      it 'rejects an address with special characters and no quotes' do
        group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', alias_email_address: 'Foo: bar <foo@bar.com>')
        expect(group.save).to be_falsey
        expect(group.errors[:alias_email_address]).to eq(['is invalid'])
      end

      it 'rejects an address that is malformed' do
        group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', alias_email_address: 'your mom')
        expect(group.save).to be_falsey
        expect(group.errors[:alias_email_address]).to eq(['is invalid'])
      end

      it 'rejects an address that is all whitespace' do
        group = Group.new(name: 'Foo', organization_id: 1, subject_tag: '', alias_email_address: ' ')
        expect(group.save).to be_falsey
        expect(group.errors[:alias_email_address]).to eq(['is invalid'])
      end
    end
  end

  describe "#name=" do
    it "creates a new email_address_tag if the email_address_tag is blank" do
      group = Group.create(name: 'fall down a hole', organization_id: 1)
      expect(group.save).to be_truthy
      expect(group.email_address_tag).to eq('fall-down-a-hole')
    end

    it "generates lowercase email_address_tags from uppercase names" do
      group = Group.create(name: 'Fall Down a Hole', organization_id: 1)
      expect(group.save).to be_truthy
      expect(group.email_address_tag).to eq('fall-down-a-hole')
    end

    it "does not reset the email_address_tag when the group is renamed" do
      group = Group.create(name: 'Fall Down a Hole', organization_id: 1)
      expect(group.save).to be_truthy
      expect(group.email_address_tag).to eq('fall-down-a-hole')

      group.name = 'foo bar'
      expect(group.save).to be_truthy
      expect(group.email_address_tag).to eq('fall-down-a-hole')
    end
  end
end
