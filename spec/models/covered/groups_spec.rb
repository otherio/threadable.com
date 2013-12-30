require 'spec_helper'

describe Covered::Groups do

  let(:groups){ described_class.new(covered) }
  subject{ groups }

  it { should have_constant :Create }

  let(:group_record){ double(:group_record) }
  let(:group){ double(:group) }

  describe '#create' do
    it 'called Covered::Groups::Create.call' do
      expect(described_class::Create).to receive(:call).with(groups, name: 'foo', organization_id: 5).and_return(group)
      expect(groups.create(name: 'foo', organization_id: 5)).to be group
    end
  end

  describe '#create!' do
    before{ expect(groups).to receive(:create).with(name: 'foo', organization_id: 5).and_return(group) }

    context 'when the group is saved' do
      before{ expect(group).to receive(:persisted?).and_return(true) }
      it 'return the group' do
        expect( groups.create!(name: 'foo', organization_id: 5) ).to eq group
      end
    end

    context 'when the group is not saved' do
      before do
        errors = double(:errors, full_messages: ['cannot be lame', 'cannot be stupid'])
        expect(group).to receive(:persisted?).and_return(false)
        expect(group).to receive(:errors).and_return(errors)
      end
      it 'return the group' do
        expect{ groups.create!(name: 'foo', organization_id: 5) }.to raise_error(
          Covered::RecordInvalid, "Group invalid: cannot be lame and cannot be stupid")
      end
    end
  end
end
