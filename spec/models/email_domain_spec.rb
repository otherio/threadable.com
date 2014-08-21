# encoding: UTF-8
require 'spec_helper'

describe EmailDomain, type: :model, fixtures: false do

  it { is_expected.to belong_to(:organization) }
  it { is_expected.to validate_presence_of :domain }
  it { is_expected.to validate_uniqueness_of :domain }

  it "should validate that there is only one outgoing domain for any given organization" do
    organization = Organization.create!(name: 'Foo', slug: 'foo')
    expect(organization.email_domains.length).to eq 0
    organization.email_domains.create(domain: 'foo.com', outgoing: true)
    expect(organization.email_domains.first).to be_outgoing

    invalid_domain = organization.email_domains.create(domain: 'bar.com', outgoing: true)
    expect(invalid_domain.errors.messages).to eq({base: ["there can be only one outgoing domain"] })
  end

  describe 'domain format validations' do

    def email_domain domain
      described_class.create(domain: domain)
    end

    def self.escape_unicode string
      string.bytes.to_a.map(&:chr).join.inspect
    end

    valid_domains = [
      %(cover.io),
      %(foo.bar.com),
      %(deadlyicon.com),
      %(localhost),
      %(wtf.motorcycles),
    ]

    invalid_domains = [
      %(jared),
      %(.biz),
      %(foo@bar.com),
    ]

    valid_domains.each do |domain|
      context "when given the domain #{escape_unicode(domain)}" do
        it "should be valid" do
          expect(email_domain(domain).errors[:domain].size).to eq(0)
        end
      end
    end

    invalid_domains.each do |domain|
      context "when given the domain #{escape_unicode(domain)}" do
        it 'should be invalid' do
          expect(email_domain(domain).errors[:domain].size).to eq(1)
        end
      end
    end
  end

end
