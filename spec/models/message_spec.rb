require 'spec_helper'

describe Message, :type => :model do
  let(:message){ Message.where(subject: 'layup body carbon').last! }
  subject{ message }

  it { is_expected.to belong_to(:parent_message) }
  it { is_expected.to belong_to(:conversation) }

  it "has a message id with a predictable domain (not some heroku crap hostname)" do
    expect(subject.message_id_header).to match(/^<.+\@localhost>$/)
  end

  context "with a parent message" do
    let(:parent_message) { message.parent_message } #create(:message, references_header: '<more-message-ids@foo.com>') }

    it "inherits references from it parent message, and adds the parent's message id to references" do
      message.save
      expect(parent_message.references_header).to be_present
      expect(parent_message.message_id_header).to be_present
      expect(message.references_header).to eq([parent_message.references_header, parent_message.message_id_header].join(' '))
    end
  end

  describe "#unique_id" do
    it "returns the message_id_header url safe base 64 encoded" do
      message = subject
      message.message_id_header = '<foo_bar_baz@example.com>'
      expect(message.unique_id).to eq(Base64.urlsafe_encode64(message.message_id_header))
    end
  end

  describe 'search' do
    before do
      message.update(body_plain: body_plain, body_html: body_html)
    end

    describe "#body_html_for_search" do
      context 'when body plain is 5k' do
        let(:body_plain) { 'a' * 5120 }
        let(:body_html) { 'b' * 5120 }
        it 'returns the first 4.5k of the html' do
          expect(subject.body_html_for_search.length).to eq(4608)
        end
      end

      context 'when the body plain is 10k' do
        let(:body_plain) { 'a' * 10240 }
        let(:body_html) { 'b' * 5120 }

        it 'returns an empty string' do
          expect(subject.body_html_for_search.length).to eq(0)
        end
      end

      context 'when the body plain is 0k' do
        let(:body_plain) { '' }
        let(:body_html) { 'b' * 10240 }

        it 'returns the first 9.5k of the body_html' do
          expect(subject.body_html_for_search.length).to eq(9728)
        end
      end

      context 'when the html body contains html' do
        let(:body_plain) { '' }
        let(:body_html) { '<b>hi</b>' }

        it 'returns the body html as plaintext' do
          expect(subject.body_html_for_search).to eq("hi")
        end
      end

    end

    describe "#body_plain_for_search" do
      let(:body_plain) { 'a' * 15360 }
      let(:body_html) { '' }

      it 'returns the first 9.5k of body_plain' do
        expect(subject.body_plain_for_search.length).to eq(9728)
      end
    end
  end
end
