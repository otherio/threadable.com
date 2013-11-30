class Attachment < ActiveRecord::Base

  def self.create_from_file!(file)
    content_type = file.content_type.split(';').first

    if Storage.local?
      local_file = Storage.files.create(
        key: "#{SecureRandom.uuid}/#{file.filename}",
        body: file.body.decoded,
        public: true,
      )
      pathname = Storage.pathname_for local_file
      create!(
        url:      local_file.public_url,
        filename: file.filename,
        mimetype: content_type,
        size:     pathname.size,
      )
    else
      body            = StringIO.new(file.body.decoded)
      uploadable_file = UploadIO.new(body, content_type, file.filename)
      filepicker_data = FilepickerUploader.upload(uploadable_file)
      create!(
        url:      filepicker_data["url"],
        filename: filepicker_data["filename"],
        mimetype: filepicker_data["type"],
        size:     filepicker_data["size"],
      )
    end
  end

  validates :url, :presence => true

  def binary?
    MIME::Types[mimetype].first.try(:binary?)
  end

  def content
    @content ||=  if url[0] == '/'
      Rails.root.join('public', url[1..-1]).read
    else
      HTTParty.get(url)
    end
  end

end
