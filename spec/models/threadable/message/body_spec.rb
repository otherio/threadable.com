require 'spec_helper'

describe Threadable::Message::Body, :type => :model do

  context 'when given html and plain content' do
    subject{ described_class.call('<p>hi</p>', 'hi')}
    it { is_expected.to eq('<p>hi</p>') }
    it { is_expected.to be_html }
  end

  context 'when given just html content' do
    subject{ described_class.call('<p>hi</p>', nil)}
    it { is_expected.to eq('<p>hi</p>') }
    it { is_expected.to be_html }
  end

  context 'when given just plain content' do
    subject{ described_class.call(nil, 'hi')}
    it { is_expected.to eq('hi') }
    it { is_expected.not_to be_html }
  end

  context 'when given no content' do
    subject{ described_class.call(nil, nil)}
    it { is_expected.to eq('') }
    it { is_expected.not_to be_html }
  end

end
