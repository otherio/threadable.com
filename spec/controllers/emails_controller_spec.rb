require 'spec_helper'

describe EmailsController do

  describe "POST create" do
    before do
      EmailProcessor.should_receive(:process_request).with(request).and_return(success)
      post :create, {}
      response.body.should be_blank
    end
    context "when the request is processed succesfully" do
      let(:success){ true }
      it "should return 200" do
        response.status.should == 200
      end
    end
    context "when the request is not processed succesfully" do
      let(:success){ false }
      it "should return 400" do
        response.status.should == 400
      end
    end
  end

end
