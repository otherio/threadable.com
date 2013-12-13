require 'spec_helper'

describe Covered::Worker do

  let :worker do
    Class.new Covered::Worker
  end

  context 'when perform! raises an exception' do
    it 'reports it to mixpanel and honeybadger' do
      exception = StandardError.new('i dont want your life!')
      instance = worker.new
      instance.jid = '123456'
      expect(instance).to receive(:perform!).with(:a, :b, :c).and_raise(exception)
      expect_any_instance_of(Covered::Class).to receive(:report_exception!).with(exception)
      expect{ instance.perform(covered.env, :a, :b, :c) }.to raise_error(exception)
    end
  end

end
