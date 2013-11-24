module RSpec::Support::Attachments

  def attachments_path
    Rails.root + 'lib/fixtures/attachments'
  end

  def uploaded_file(path, content_type, binary)
    Rack::Test::UploadedFile.new((attachments_path+path).to_s, content_type, binary)
  end

  extend self

end
