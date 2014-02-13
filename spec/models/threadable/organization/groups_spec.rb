require 'spec_helper'

describe Threadable::Organization::Groups do

  it { should have_constant :Create }

  let(:organization_record){ double(:organization_record, id: 18) }
  let(:organization){ double(:organization,
    threadable: threadable,
    organization_record: organization_record,
    id: organization_record.id,
    subject_tag: 'tag')
  }
  let(:groups){ described_class.new(organization) }
  subject{ groups }

  let(:group_record){ double(:group_record, auto_join?: false) }
  let(:group){ double(:group) }

  describe '#create' do
    it 'called Threadable::Groups::Create.call' do
      expect(::Group).to receive(:create).with(name: 'foo', organization: organization_record, subject_tag: 'tag+foo').and_return(group_record)
      group = groups.create(name: 'foo')
      expect(group.group_record).to eq group_record
    end
  end

  describe '#create!' do
    before{ expect(groups).to receive(:create).with(name: 'foo').and_return(group) }

    context 'when the group is saved' do
      before{ expect(group).to receive(:persisted?).and_return(true) }
      it 'return the group' do
        expect( groups.create!(name: 'foo') ).to eq group
      end
    end

    context 'when the group is not saved' do
      before do
        errors = double(:errors, full_messages: ['cannot be lame', 'cannot be stupid'])
        expect(group).to receive(:persisted?).and_return(false)
        expect(group).to receive(:errors).and_return(errors)
      end
      it 'return the group' do
        expect{ groups.create!(name: 'foo') }.to raise_error(
          Threadable::RecordInvalid, "Group invalid: cannot be lame and cannot be stupid")
      end
    end
  end

end
