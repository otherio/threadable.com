class StoreIncomingAttachment < MethodObject.new(:name, :body, :content_type)

  def call
    store_file!
    create_attachment_record!
    @attachment
  end

  def store_file!
    uuid = SecureRandom.uuid
    file = Storage.put("attachments/#{uuid}", @body)
    @url = file.public_url
  end

  def create_attachment_record!
    @attachment = Attachment.create!(
      url: @url,
      filename: @name,
      mimetype: @content_type,
    )
  end

end
