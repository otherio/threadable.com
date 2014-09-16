require 'spec_helper'

describe Threadable::Groups, :type => :request do

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:groups){ organization.groups }
  let(:primary_group){ organization.groups.primary }
  let(:electronics) { organization.groups.find_by_email_address_tag('electronics') }
  let(:fundraising) { organization.groups.find_by_email_address_tag('fundraising') }
  let(:graphic_design) { organization.groups.find_by_email_address_tag('graphic-design') }

  subject{ groups }

  describe '#all' do
    it 'returns all the groups' do
      expect(threadable.groups.all.map(&:slug)).to match_array ["adminteam", "sfhealth", "social", "triage", "anesthiology", "cardiology", "raceteam", "electronics", "fundraising", "graphic-design", "press", "leaders"]
    end
  end
end
