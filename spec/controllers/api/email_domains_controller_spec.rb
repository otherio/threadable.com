require 'spec_helper'

describe Api::EmailDomainsController do
  let(:raceteam){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:sfhealth){ threadable.organizations.find_by_slug! 'sfhealth' }

  describe '#index' do
    when_signed_in_as 'bob@ucsd.example.com' do
      context "when given a valid organization id" do
        it "returns the email domains as json" do
          xhr :get, :index, format: :json, organization_id: raceteam.slug
          expect(response.status).to eq 200
          domains = raceteam.email_domains.all
          expect(response.body).to eq serialize(:email_domains, domains).to_json
        end
      end
    end
  end

  describe '#create' do
    when_signed_in_as 'bob@ucsd.example.com' do
      context "when given a valid organization id" do
        it "creates the domain and renders it as json" do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, email_domain: { domain: 'foo.com', outgoing: false }
          expect(response.status).to eq 201
          domain = raceteam.email_domains.find_by_domain('foo.com')
          expect(domain).to be_present

          expect(response.body).to eq serialize(:email_domains, domain).to_json
        end
      end

      context "when given an organization id of an organization that does not exist" do
        it 'renders not found' do
          xhr :post, :create, format: :json, organization_id: 'foobar', email_domain: { domain: 'foo.com', outgoing: false }
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug \"foobar\""}'
        end
      end
      context 'when given an organization id of an organization that the current user is not in' do
        it 'renders not found' do
          xhr :post, :create, format: :json, organization_id: sfhealth.slug, email_domain: { domain: 'foo.com', outgoing: false }
          expect(response.status).to eq 404
          expect(response.body).to eq '{"error":"unable to find organization with slug \"sfhealth\""}'
        end
      end
      context 'when given no organization id' do
        it 'renders not acceptable' do
          xhr :post, :create, format: :json, email_domain: { domain: 'foo.com', outgoing: false }
          expect(response.status).to eq 406
          expect(response.body).to eq '{"error":"param is missing or the value is empty: organization_id"}'
        end
      end
    end
  end

  describe '#update' do
    when_signed_in_as 'bob@ucsd.example.com' do
      context "when given a valid organization id" do
        let(:domain) { raceteam.email_domains.find_by_domain('raceteam.com') }
        it "updates the domain's outgoing flag" do
          xhr :put, :update, format: :json, id: domain.id, organization_id: raceteam.slug, email_domain: { domain: 'raceteam.com', outgoing: true }
          expect(response.status).to eq 200
          found_domain = raceteam.email_domains.find_by_domain('raceteam.com')
          expect(found_domain).to be_present
          expect(found_domain.outgoing?).to be_true

          expect(response.body).to eq serialize(:email_domains, found_domain).to_json
        end
      end
    end
  end

  describe '#destroy' do
    when_signed_in_as 'bob@ucsd.example.com' do
      context "when given a valid organization id" do
        let(:domain) { raceteam.email_domains.find_by_domain('raceteam.com') }
        it "removes the domain" do
          xhr :delete, :destroy, format: :json, id: domain.id, organization_id: raceteam.slug
          expect(response.status).to eq 200
          expect(raceteam.email_domains.find_by_domain('raceteam.com')).to_not be_present
          expect(response.body).to eq '{}'
        end
      end
    end
  end

end
