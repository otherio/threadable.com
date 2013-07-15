class TestEnvironment::Attachments

  def self.uploaded_file(path, content_type, binary)
    Rack::Test::UploadedFile.new("#{TestEnvironment.fixture_path}/attachments/#{path}", content_type, binary)
  end

  def uploaded_file(path, content_type, binary)
    TestEnvironment::Attachments.uploaded_file(path, content_type, binary)
  end

end
