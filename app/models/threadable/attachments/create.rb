class Threadable::Attachments::Create < MethodObject

  def call attachments, attributes
    @attachments = attachments
    @threadable  = attachments.threadable
    @attributes  = attributes

    @filename = @attributes.fetch(:filename)
    @mimetype = @attributes.fetch(:mimetype).to_s.split(';').first
    if @attributes.key?(:url)
      @url  = @attributes[:url]
      @size = @attributes[:size]
    else
      @content = @attributes.fetch(:content)
      store_file!
    end
    @content_id = attributes[:content_id]
    @inline = !! attributes[:inline]
    create_attachment_record!
    Threadable::Attachment.new(@threadable, @attachment_record)
  end

  def store_file!
    if Storage.local?
      store_file_locally!
    else
      store_file_via_filepicker!
    end
  end

  def create_attachment_record!
    @attachment_record = ::Attachment.create(
      url:        @url,
      filename:   @filename,
      mimetype:   @mimetype,
      size:       @size,
      writeable:  "true",
      content_id: @content_id,
      inline:     @inline,
    )
  end

  def store_file_locally!
    local_file = Storage.files.create(
      key: "#{SecureRandom.uuid}/#{@filename}",
      body: @content,
      public: true,
    )
    @url  = local_file.public_url
    @size = Storage.pathname_for(local_file).size
  end

  def store_file_via_filepicker!
    uploadable_file = UploadIO.new(StringIO.new(@content), @mimetype, @filename)
    filepicker_data = FilepickerUploader.upload(uploadable_file)

    @url      = filepicker_data["url"]
    @filename = filepicker_data["filename"]
    @mimetype = filepicker_data["type"]
    @size     = filepicker_data["size"]
  end
end
