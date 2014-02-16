require 'spec_helper'

describe Threadable::ScheduledWorker do

  let :worker do
    Class.new described_class
  end

  context 'when the job is specified with only times' do
    it 'sets the worker flag on the threadable object' do
      instance = worker.new
      instance.jid = '123456'
      instance.stub(:perform!)
      instance.perform(50.10242, 100.348295)
      expect(instance.threadable.worker).to be_true
    end
  end

  context 'when the times are missing' do
    it 'sets the worker flag on the threadable object, and uses the current day' do
      instance = worker.new
      instance.jid = '123456'
      instance.stub(:perform!)
      instance.perform
      expect(instance.threadable.worker).to be_true
    end
  end
end
