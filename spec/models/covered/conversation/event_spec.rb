require 'spec_helper'

describe Covered::Conversation::Event do

  let(:conversation){ double :conversation }
  let(:event_record){ double :event_record }
  let(:event       ){ described_class.new(covered, event_record, conversation) }
  subject{ event }

  its(:covered     ){ should eq covered      }
  its(:event_record){ should eq event_record }
  its(:conversation){ should eq conversation }

end
