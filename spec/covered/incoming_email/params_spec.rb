require 'spec_helper'

describe Covered::IncomingEmail::Params do

  let(:params){ create_incoming_email_params }

  delegate :dump, :load, to: described_class

  it "should be able to handle File instances" do
    encoded_params = dump(params)
    decoded_params = load(encoded_params)

    expect(encoded_params).to be_a String

    params.each do |key, expected_value|
      decoded_value = decoded_params.fetch(key)
      case key
      when /^attachment-\d+$/
        expect_attachments_to_be_equal(expected_value, decoded_value)
      else
        expect(decoded_value).to eq(expected_value)
      end
    end

  end

  describe ".dump" do
  end

  describe ".load" do
  end

  def expect_attachments_to_be_equal(expected_attachment, decoded_attachment)
    expected_attachment.seek(0)
    expect(decoded_attachment.original_filename).to eq(expected_attachment.original_filename)
    expect(decoded_attachment.content_type     ).to eq(expected_attachment.content_type)
    expect(decoded_attachment.read             ).to eq(expected_attachment.read)
  end

end
