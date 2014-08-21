require 'spec_helper'

describe FormattedEmailAddress, :type => :model do

  let(:formatted_email_address){ described_class.new(options) }
  subject{ formatted_email_address }


  context "when given just an address" do
    let :options do
      {
        address: 'jared@other.io',
      }
    end

    describe '#to_s' do
      subject { super().to_s }
      it { is_expected.to eq 'jared@other.io' }
    end
  end


  context "when given an address and a display name with special characters" do
    let :options do
      {
        address: 'jared@other.io',
        display_name: "Jared Grippe: A Person",
      }
    end

    describe '#to_s' do
      subject { super().to_s }
      it { is_expected.to eq %("Jared Grippe: A Person" <jared@other.io>) }
    end
  end

  context "when given an address and a display name without special characters" do
    let :options do
      {
        address: 'jared@other.io',
        display_name: "Jared Grippe",
      }
    end

    describe '#to_s' do
      subject { super().to_s }
      it { is_expected.to eq %(Jared Grippe <jared@other.io>) }
    end
  end

  context "when given an address and a nil display name" do
    let :options do
      {
        address: 'jared@other.io',
        display_name: nil,
      }
    end

    describe '#to_s' do
      subject { super().to_s }
      it { is_expected.to eq %(jared@other.io) }
    end
  end

  context "when given an address and a blank display name" do
    let :options do
      {
        address: 'jared@other.io',
        display_name: ' ',
      }
    end

    describe '#to_s' do
      subject { super().to_s }
      it { is_expected.to eq %(jared@other.io) }
    end
  end

  context "when given a string with unicode charaters" do
    let :options do
      {
        address: 'jaréd@other.io',
        display_name: 'Järéd Grîppé',
      }
    end

    describe '#to_s' do
      subject { super().to_s }
      it { is_expected.to eq %(Jared Grippe <jared@other.io>) }
    end
  end


  context "when given an address that is not a string" do
    let :options do
      address = Struct.new(:value){
        alias_method :to_s, :value
        alias_method :to_str, :to_s
      }.new('jared@other.io')
      {
        address: address,
        display_name: ' ',
      }
    end

    describe '#to_s' do
      subject { super().to_s }
      it { is_expected.to eq %(jared@other.io) }
    end
  end


end
