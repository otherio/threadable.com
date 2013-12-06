require 'spec_helper'

describe Covered::Message::Body do

  context 'when given html and plain content' do
    subject{ described_class.call('<p>hi</p>', 'hi')}
    it { should == '<p>hi</p>' }
    it { should be_html }
  end

  context 'when given just html content' do
    subject{ described_class.call('<p>hi</p>', nil)}
    it { should == '<p>hi</p>' }
    it { should be_html }
  end

  context 'when given just plain content' do
    subject{ described_class.call(nil, 'hi')}
    it { should == 'hi' }
    it { should_not be_html }
  end

end
