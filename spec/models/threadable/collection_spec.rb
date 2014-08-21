require 'spec_helper'

describe Threadable::Collection, :type => :model do
  subject{ described_class }

  it{ is_expected.to include Let }

end
