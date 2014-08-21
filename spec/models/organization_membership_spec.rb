require 'spec_helper'

describe OrganizationMembership, :type => :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :organization }

  subject{ OrganizationMembership.new attributes }

  def attributes
    {

    }
  end

end
