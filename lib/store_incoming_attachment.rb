class StoreIncomingAttachment < MethodObject.new(:project_slug, :file)

  def call
    filename        = @file.filename
    content_type    = @file.content_type.split(';').first
    body            = StringIO.new(@file.body.decoded)
    uploadable_file = UploadIO.new(body, content_type, filename)
    filepicker_data = FilepickerUploader.upload(uploadable_file)

    Attachment.create!(
      url:      filepicker_data["url"],
      filename: filepicker_data["filename"],
      mimetype: filepicker_data["type"],
      size:     filepicker_data["size"],
    )
  end

end
