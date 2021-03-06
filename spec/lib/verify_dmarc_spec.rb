require 'spec_helper'

include Dnsruby

describe VerifyDmarc, fixtures: false do
  delegate :call, to: described_class

  let(:resolver) { double(:resolver, query: dns_query) }
  let(:dns_query) { double(:dns_query, answer: answer ) }
  let(:address) { Mail::Address.new('Foo Guy <foo@bar.com>') }

  # stub the Dnsruby response
  let(:answer) { [ double(:dns_record1, rdata: rdata, type: 'TXT') ] }
  let(:rdata) { ["v=DMARC1; p=#{policy}; rua=mailto:mailauth-reports@foo.com"] }
  let(:policy) { 'none' }

  before do
    allow(described_class).to receive(:call).and_call_original
    allow(Dnsruby::Resolver).to receive(:new).and_return(resolver)
  end

  context 'when the address is not a cname' do
    it 'queries the DMARC txt record for the email address domain' do
      expect(resolver).to receive(:query).with('_dmarc.bar.com', Types.TXT)
      call(address)
    end

    it 'queries the DMARC txt record once, and returns the value from redis the second time' do
      pending "For the moment, this seems to break dmarc checking sometimes."
      expect(resolver).to receive(:query).with('_dmarc.bar.com', Types.TXT).once
      call(address)
      call(address)
    end

    describe 'checking the dmarc policy' do
      context 'with a dmarc policy of quarantine' do
        let(:policy) { 'quarantine' }
        it 'returns false' do
          expect(call(address)).to be_falsey
        end
      end

      context 'when the policy spec is uppercase' do
        let(:policy) { 'QUARANTINE' }
        it 'returns false' do
          expect(call(address)).to be_falsey
        end
      end

      context 'with a dmarc policy of none' do
        let(:policy) { 'none' }
        it 'returns true' do
          expect(call(address)).to be_truthy
        end
      end

      context 'with a dmarc policy that rejects unmatched domains' do
        let(:policy) { 'reject' }
        it 'returns false' do
          expect(call(address)).to be_falsey
        end
      end

      context 'with an incorrect or unsupported dmarc policy' do
        let(:policy) { 'delicious_brownies' }
        it 'returns true' do
          expect(call(address)).to be_truthy
        end
      end

      context 'when dns lookup fails' do
        before do
          expect(resolver).to receive(:query).and_raise(Dnsruby::NXDomain)
        end
        it 'returns true' do
          expect(call(address)).to be_truthy
        end
      end
    end
  end

  context 'when address is a cname' do
    let(:rdata) { "_dmarc.fooalicious.com" }
    let(:answer) { [ double(:dns_record1, type: 'CNAME', rdata: rdata) ] }

    let(:rdata2) { ["v=DMARC1; p=#{policy}; rua=mailto:mailauth-reports@foo.com"] }
    let(:answer2) { [ double(:dns_record1, type: 'TXT', rdata: rdata2) ] }
    let(:dns_query2) { double(:dns_query, answer: answer2 ) }

    before do
      allow(resolver).to receive(:query).with('_dmarc.bar.com', Types.TXT).and_return(dns_query)
      allow(resolver).to receive(:query).with('_dmarc.fooalicious.com', Types.TXT).and_return(dns_query2)
    end

    context 'and the cname destination has a dmarc record' do
      context 'with a dmarc policy of none' do
        let(:policy) { 'none' }
        it 'returns true' do
          expect(call(address)).to be_truthy
        end
      end

      context 'with a dmarc policy that rejects unmatched domains' do
        let(:policy) { 'reject' }
        it 'returns false' do
          expect(call(address)).to be_falsey
        end
      end
    end

    context 'when the records are self-referential' do
      let(:rdata2) { ["_dmarc.bar.com"] }
      let(:answer2) { [ double(:dns_record1, type: 'CNAME', rdata: rdata2) ] }

      it 'does not get stuck in an infinite loop' do
        expect(call(address)).to be_truthy
      end
    end
  end

end
