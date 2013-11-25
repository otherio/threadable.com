require 'spec_helper'

describe Covered::Project do

  %w{
    Members
    Member
    Conversations
    Conversation
    Tasks
    Task
  }.each do |constant|
    describe "::#{constant}" do
      specify{ "#{described_class}::#{constant}".constantize.name.should == "#{described_class}::#{constant}" }
    end
  end

end
