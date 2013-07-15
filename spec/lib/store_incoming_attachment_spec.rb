require 'spec_helper'

describe StoreIncomingAttachment do

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


    expect(StoreIncomingAttachment.call(file)).to be(attachment)
  end

end
