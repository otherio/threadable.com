module TestEnvironment::Filepicker

  def mock_filepicker_upload_for(expected_file)
    url = "https://www.filepicker.io/api/file/#{SecureRandom.uuid.gsub('-','')}"
    filename = expected_file.respond_to?(:original_filename) ?
      expected_file.original_filename : File.basename(expected_file.path)
    content_type = Mime::Type.lookup_by_extension(File.extname(filename)[1..-1]).to_s

    response = {
      "url"      => url,
      "size"     => expected_file.size,
      "type"     => content_type,
      "filename" => filename,
    }

    expected_url = "#{FilepickerUploader.uri.path}?#{FilepickerUploader.uri.query}"
    expected_options = {query: {fileUpload: duck_type(:original_filename)}}

    verify_args = ->(url, options) do
      expect(options[:query][:fileUpload].original_filename).to eq(filename)
    end

    FilepickerUploader::Uploader.
      should_receive(:post).
      with(expected_url, expected_options, &verify_args).
      and_return(response)

    expected_file.seek(0) if expected_file.respond_to? :seek

    stub_filepicker_get_request({
      url: url,
      content_type: content_type,
      body: expected_file.read,
    })
  end

  # stub_filepicker_get_request({
  #   url: url,
  #   content_type: content_type,
  #   body: body,
  # })
  def stub_filepicker_get_request(options)
    stub_request(:get, options[:url]).to_return(
      :status => 200,
      :body => options[:body],
      :headers => {'Content-Type' => options[:content_type]}
    )
  end

end
