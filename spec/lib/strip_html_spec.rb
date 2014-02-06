require 'spec_helper'

describe StripHtml do

  delegate :call, to: :described_class

  context 'with html' do
    let(:html) { "<p>hi</p><div>this is some text</div><br>\n<b>more text</b>" }
    it 'removes the html' do
      expect(call(html)).to eq "hi this is some text more text"
    end
  end

  context 'with plain text' do
    let(:text) { "this is text more text" }
    it 'strips newlines' do
      # not desired behavior, but good enough for now.
      expect(call(text)).to eq text
    end
  end

  context 'with an empty string' do
    let(:html) { "" }
    it 'returns empty string' do
      expect(call(html)).to be_empty
    end
  end

  context 'with nil' do
    let(:html) { nil }
    it 'returns nil' do
      expect(call(html)).to be_nil
    end
  end

  context 'with false' do
    let(:html) { false }
    it 'returns nil' do
      expect(call(html)).to be_nil
    end
  end
end
