require 'spec_helper'

describe Threadable::Worker do

  let :worker do
    Class.new Threadable::Worker
  end

  context 'when perform! raises an exception' do
    it 'reports it to mixpanel and honeybadger' do
      exception = StandardError.new('i dont want your life!')
      instance = worker.new
      instance.jid = '123456'
      expect(instance).to receive(:perform!).with(:a, :b, :c).and_raise(exception)
      expect_any_instance_of(Threadable::Class).to receive(:report_exception!).with(exception)
      expect{ instance.perform(threadable.env, :a, :b, :c) }.to raise_error(exception)
    end
  end

  context 'when the job is correct' do
    it 'sets the worker flag on the threadable object' do
      instance = worker.new
      instance.jid = '123456'
      instance.stub(:perform!)
      instance.perform(threadable.env, :a)
      expect(instance.threadable.worker).to be_true
    end
  end
end
