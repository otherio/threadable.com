require 'spec_helper'

include Dnsruby

describe VerifyDmarc, fixtures: false do
  delegate :call, to: described_class

  let(:resolver) { double(:resolver, query: dns_query) }
  let(:dns_query) { double(:dns_query, answer: answer ) }
  let(:address) { Mail::Address.new('Foo Guy <foo@bar.com>') }

  # stub the Dnsruby response
  let(:answer) { [ double(:dns_record1, rdata: rdata) ] }
  let(:rdata) { ["v=DMARC1; p=#{policy}; rua=mailto:mailauth-reports@foo.com"] }
  let(:policy) { 'quarantine' }

  before do
    Dnsruby::Resolver.stub(:new).and_return(resolver)
  end

  it 'queries the DMARC txt record for the email address domain' do
    expect(resolver).to receive(:query).with('_dmarc.bar.com', Types.TXT)
    call(address)
  end

  describe 'checking the dmarc policy' do
    context 'with a dmarc policy that allows unmatched domains' do
      it 'returns true' do
        expect(call(address)).to be_true
      end
    end

    context 'with a dmarc policy of none' do
      let(:policy) { 'none' }
      it 'returns true' do
        expect(call(address)).to be_true
      end
    end

    context 'with a dmarc policy that rejects unmatched domains' do
      let(:policy) { 'reject' }
      it 'returns false' do
        expect(call(address)).to be_false
      end
    end

    context 'with an incorrect or unsupported dmarc policy' do
      let(:policy) { 'delicious_brownies' }
      it 'returns true' do
        expect(call(address)).to be_true
      end
    end

    context 'when dns lookup fails' do
      before do
        expect(resolver).to receive(:query).and_raise(Dnsruby::NXDomain)
      end
      it 'returns true' do
        expect(call(address)).to be_true
      end
    end
  end
end
