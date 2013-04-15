require 'spec_helper'

describe ProcessEmailWorker do

  it "should call EmailProcessor.process_email(@email)" do
    EmailProcessor.should_receive(:process_email).with('THIS IS A CRAZY OL\' EMAIL', 'ALSO STRIPPED HOLY CRAP')
    ProcessEmailWorker.perform('THIS IS A CRAZY OL\' EMAIL', 'ALSO STRIPPED HOLY CRAP')
  end

end
