require 'spec_helper'

describe Threadable::Organization::Ungrouped do

  let(:organization_record){ double :organization_record }
  let(:organization){ double :organization, threadable: threadable, organization_record: organization_record }

  subject{ described_class.new(organization) }

  its(:threadable)         { should be threadable }
  its(:organization)       { should be organization }
  its(:organization_record){ should be organization_record }


end
