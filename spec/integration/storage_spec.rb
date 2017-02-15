# encoding: UTF-8

require 'spec_helper'

describe 'storage', :type => :request do

  it "should write a file that is readable" do
    gif = attachments_path.join('some.gif')
    file = Storage.files.create(
      key: "#{SecureRandom.uuid}/some.gif",
      body: gif.read,
      public: true,
    )

    file.reload
    gif_body = gif.read(:encoding => 'ASCII-8BIT')

    expect(file.body.encoding).to eq gif_body.encoding
    expect(file.body).to eq gif_body
    get file.public_url
    expect(response.headers["Content-Type"]).to eq file.content_type
    expect(response.body.force_encoding(file.body.encoding)).to eq gif_body
  end

end
