# encoding: UTF-8
require 'spec_helper'

describe "flash_messages" do

  let :flash do
    {
      message: 'FLASH MESSAGE',
      error:   'FLASH ERROR',
      notice:  'FLASH NOTICE',
      alert:   'FLASH ALERT',
    }
  end

  before do
    view.stub(:flash).and_return(flash)
  end

  it "should render all the flash messages" do
    html.css('div.message.alert.alert-success').text.should   == "\n×\nHey!\nFLASH MESSAGE\n"
    html.css('div.error.alert.alert-error').text.should       == "\n×\nError!\nFLASH ERROR\n"
    html.css('div.notice.alert.alert-info').text.should       == "\n×\nNotice!\nFLASH NOTICE\n"
    html.css('div.alert.alert-error:not(.error)').text.should == "\n×\nAlert!\nFLASH ALERT\n"
  end


end
