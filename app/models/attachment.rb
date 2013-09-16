class Attachment < ActiveRecord::Base

  def self.create_from_file!(file)
    filename        = file.filename
    content_type    = file.content_type.split(';').first
    body            = StringIO.new(file.body.decoded)
    uploadable_file = UploadIO.new(body, content_type, filename)
    filepicker_data = FilepickerUploader.upload(uploadable_file)

    create!(
      url:      filepicker_data["url"],
      filename: filepicker_data["filename"],
      mimetype: filepicker_data["type"],
      size:     filepicker_data["size"],
    )
  end

  validates :url, :presence => true

  def binary?
    MIME::Types[mimetype].first.try(:binary?)
  end

  def content
    @content ||= HTTParty.get(url)
  end

end
