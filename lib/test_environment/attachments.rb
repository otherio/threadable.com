module TestEnvironment::Attachments

  def attachments_path
    fixtures_path + 'attachments'
  end

  def uploaded_file(path, content_type, binary)
    Rack::Test::UploadedFile.new((attachments_path+path).to_s, content_type, binary)
  end

end
