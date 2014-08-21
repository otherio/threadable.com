require 'spec_helper'

describe Threadable::ScheduledWorker, :type => :model do

  let :worker do
    Class.new described_class
  end

  context 'when the job is specified with only times' do
    it 'sets the worker flag on the threadable object' do
      instance = worker.new
      instance.jid = '123456'
      allow(instance).to receive(:perform!)
      instance.perform(50.10242, 100.348295)
      expect(instance.threadable.worker).to be_truthy
    end
  end

  context 'when the times are missing' do
    it 'sets the worker flag on the threadable object, and uses the current day' do
      instance = worker.new
      instance.jid = '123456'
      allow(instance).to receive(:perform!)
      instance.perform
      expect(instance.threadable.worker).to be_truthy
    end
  end
end
