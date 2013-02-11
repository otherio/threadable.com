# encoding: utf-8

require 'spec_helper'

describe "page_footer" do

  describe "return value" do
    subject{ return_value }
    it { should == "© Multify 2013\n" }
  end

end
