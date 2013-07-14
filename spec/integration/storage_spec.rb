require 'spec_helper'

describe 'storage' do

  it "should write a file that is readable" do
    gif = Pathname(fixture_path).join('attachments/some.gif')
    file = Storage.files.create(
      key: "#{SecureRandom.uuid}/some.gif",
      body: gif.read,
      public: true,
    )

    file.reload
    expect(file.body).to eq gif.read
    get file.public_url
    expect(response.headers["Content-Type"]).to eq file.content_type
    expect(response.body.force_encoding(file.body.encoding)).to eq gif.read
  end

end
