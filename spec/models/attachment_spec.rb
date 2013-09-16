require 'spec_helper'

describe Attachment do

  let(:mimetype){ "text/plain" }

  let(:attributes) do
    {
      url:       "https://www.filepicker.io/api/file/RAVjsBKtRpqgzM6wvdaH",
      filename:  "some.txt",
      mimetype:  mimetype,
      size:      35,
      writeable: false,
    }
  end

  let(:attachment){ Attachment.new(attributes) }

  describe ".create_from_file!" do

    let(:file){ double(:file, filename: 'cat.jpg', body: file_body, content_type: 'image/jpeg;boosh') }
    let(:file_body){ double(:file_body, decoded: file_body_decoded) }
    let(:file_body_decoded){ double(:file_body_decoded) }
    let(:string_io_body){ double(:string_io_body) }
    let(:uploadable_file){ double(:uploadable_file) }
    let(:attachment){ double(:attachment) }

    it "should create an attachment" do

      StringIO.should_receive(:new).with(file_body_decoded).and_return(string_io_body)
      UploadIO.should_receive(:new).with(string_io_body, 'image/jpeg', 'cat.jpg').and_return(uploadable_file)

      filepicker_data = {
        "url"      => "filepicker_data[url]",
        "filename" => "filepicker_data[filename]",
        "type"     => "filepicker_data[type]",
        "size"     => "filepicker_data[size]",
      }

      FilepickerUploader.should_receive(:upload).with(uploadable_file).and_return(filepicker_data)

      Attachment.should_receive(:create!).with(
        url:      filepicker_data["url"],
        filename: filepicker_data["filename"],
        mimetype: filepicker_data["type"],
        size:     filepicker_data["size"],
      ).and_return(attachment)


      expect(Attachment.create_from_file!(file)).to be(attachment)
    end

  end

  describe "#binary?" do
    subject { attachment.binary? }
    context "when the mimetype is 'text/plain'" do
      let(:mimetype){ "text/plain" }
      it { should be_false }
    end
    context "when the mimetype is 'image/jpeg'" do
      let(:mimetype){ "image/jpeg" }
      it { should be_true }
    end

  end

  describe "#content" do
    it "should call HTTParty.get(url)" do
      expect(HTTParty).to receive(:get).once.with(attributes[:url]).and_return("FAKE CONTENT")
      expect(attachment.content).to eq "FAKE CONTENT"
      expect(attachment.content).to eq "FAKE CONTENT"
    end
  end

end
