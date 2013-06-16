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

    # I could not get Webmock or FakeWeb to work with HTTMultiParty
    FilepickerUploader::Uploader.should_receive(:post) do |url, options| #.with(file).and_return(response)
      expect(url).to eq("#{FilepickerUploader.uri.path}?#{FilepickerUploader.uri.query}")
      given_file = options.try(:[], :query).try(:[], :fileUpload)
      expect(expected_file.original_filename).to eq(given_file.original_filename)
      response
    end

    expected_file.seek(0) if expected_file.respond_to? :seek

    stub_request(:get, response["url"]).
      to_return(:status => 200, :body => expected_file.read, :headers => {
        'Content-Type' => content_type
      })

  end

end
