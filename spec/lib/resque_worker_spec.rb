require 'spec_helper'

describe ResqueWorker do

  before do
    stub_const('AGlobalHash', {})
    stub_const('TestWorker', Class.new(ResqueWorker.new(:name, :options)){
      def call
        AGlobalHash[:called] = true
        AGlobalHash[:instance_values] = instance_values
      end
    })
  end

  subject{ TestWorker }

  it { should respond_to :perform }
  it { should_not respond_to :call }



  describe ".queue" do
    subject{ TestWorker.queue }
    context "when not specified" do
      it { should be_nil }
    end
    context "when specified" do
      before{ TestWorker.queue :important }
      it { should == :important }
    end
  end

  describe ".enqueue" do
    it "should curry the given arguments to Resque.enqueue" do
      Resque.should_receive(:enqueue).with(subject, :Love, {your:'face'})
      subject.enqueue(:Love, {your:'face'})
    end
  end

  describe ".perform" do
    it "should JSON serialize and deserialize the arguments passed to perform" do
      subject.perform(:Steve, { a:'b', c: [:c, 'd'] }).should be_nil
      AGlobalHash[:instance_values].should == {"name"=>"Steve", "options"=>{"a"=>"b", "c"=>["c", "d"]}}
    end
  end

end
