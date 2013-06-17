class AttachmentPreviewWidget < Rails::Widget::Presenter

  arguments :attachment

  option :href do
    attachment.url
  end

  option :filename do
    attachment.filename
  end

  option :mimetype do
    attachment.mimetype
  end

  option :preview_src_url do
    url = URI(attachment.url)
    url.path += '/convert'
    url.query = {h:42,w:43,fit:'crop'}.to_param
    url.to_s
  end

end
