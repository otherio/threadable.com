require 'spec_helper'

describe ProcessEmailWorker do

  it "should call EmailProcessor.process_email(@email)" do
    EmailProcessor.should_receive(:call).with("some" => "params")
    ProcessEmailWorker.perform(some: :params)
  end

end
