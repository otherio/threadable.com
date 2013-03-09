require 'spec_helper'

describe ProcessEmailWorker do

  it "should call EmailProcessor.process_email(@email)" do
    EmailProcessor.should_receive(:process_email).with('THIS IS A CRAZY OL\' EMAIL')
    ProcessEmailWorker.perform('THIS IS A CRAZY OL\' EMAIL')
  end

end
