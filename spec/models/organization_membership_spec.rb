require 'spec_helper'

describe OrganizationMembership do
  it { should belong_to :user }
  it { should belong_to :organization }

  subject{ OrganizationMembership.new attributes }

  def attributes
    {

    }
  end

end
