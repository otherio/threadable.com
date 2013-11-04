require 'spec_helper'

describe Covered::BackgroundJobs do

  subject{ covered.background_jobs }

  describe '.perform' do

    let(:env){ {host: 'fark.com', port: 80, current_user_id: 332} }
    let(:operation_name){ :some_fake_operation }
    let(:options){ {my: :options} }
    let(:covered_double){ double :covered }
    let(:operations_double){ double :operations }

    it "should create a new Covered instance and call the operation with the given options" do
      expect(Covered).to receive(:new).with(env).and_return(covered_double)
      expect(covered_double).to receive(:operations).and_return(operations_double)
      expect(operations_double).to receive(operation_name).with(options)
      described_class::Worker.new.perform(env, operation_name, options)
    end
  end

  describe "enqueue" do
    it "should take an operation name and return a Covered::BackgroundJob" do
      expect{ subject.enqueue('sdfjhsdkjf') }.to raise_error ArgumentError, 'sdfjhsdkjf is not an operation'

      subject.enqueue('process_incoming_email', foo: 'bar')

      assert_background_job_enqueued(covered, :process_incoming_email, foo: 'bar')
    end
  end

end
