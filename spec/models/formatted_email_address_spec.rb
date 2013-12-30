require 'spec_helper'

describe FormattedEmailAddress do

  let(:formatted_email_address){ described_class.new(options) }
  subject{ formatted_email_address }


  context "when given just an address" do
    let :options do
      {
        address: 'jared@other.io',
      }
    end
    its(:to_s){ should eq 'jared@other.io' }
  end


  context "when given an address and a display name with special characters" do
    let :options do
      {
        address: 'jared@other.io',
        display_name: "Jared Grippe: A Person",
      }
    end
    its(:to_s){ should eq %("Jared Grippe: A Person" <jared@other.io>) }
  end

  context "when given an address and a display name without special characters" do
    let :options do
      {
        address: 'jared@other.io',
        display_name: "Jared Grippe",
      }
    end
    its(:to_s){ should eq %(Jared Grippe <jared@other.io>) }
  end

  context "when given an address and a nil display name" do
    let :options do
      {
        address: 'jared@other.io',
        display_name: nil,
      }
    end
    its(:to_s){ should eq %(jared@other.io) }
  end

  context "when given an address and a blank display name" do
    let :options do
      {
        address: 'jared@other.io',
        display_name: ' ',
      }
    end
    its(:to_s){ should eq %(jared@other.io) }
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
    its(:to_s){ should eq %(jared@other.io) }
  end


end
