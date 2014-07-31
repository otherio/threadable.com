require 'httmultiparty'

# Based on: https://developers.filepicker.io/docs/web/#fpurl-store
#
# >>> curl -X POST -F fileUpload=@filename.txt https://www.filepicker.io/api/store/S3?key=MY_API_KEY
# {"url": "https://www.filepicker.io/api/file/WmFxB2aSe20SGT2kzSsr", "size": 234, "type": "text/plain", "filename": "tester.txt", "key": "1ilWxmaRRqhMd2vSbSyB_tester.txt"}
#
# >>> curl -X POST -d url="https://www.filepicker.io/static/img/watermark.png" https://www.filepicker.io/api/store/S3?key=MY_API_KEY
# {"url": "https://www.filepicker.io/api/file/N49i6hPRBeropWnCWOLw", "size": 8331, "type": "image/png", "filename": "watermark.png", "key": "a1RyBxiglW92bS2SRmqM_watermark.png"}
#
module FilepickerUploader

  class Uploader
    include HTTMultiParty
    base_uri 'https://www.filepicker.io'
  end

  def self.api_key
    ::Rails.application.config.filepicker_rails.api_key
  end

  def self.path
    "/api/store/S3"
  end

  def self.params
    {key: api_key}
  end

  def self.uri
    @uri ||= URI(Uploader.base_uri).tap do |uri|
      uri.path = path
      uri.query = params.to_param
    end
  end

  UploadError = Class.new(StandardError)

  def self.upload(file)
    raise UploadError, "Attempted to upload zero-length file: #{file.original_filename}" if file.io.length == 0

    response = Uploader.post("#{uri.path}?#{uri.query}", query: {fileUpload: file})
    raise UploadError, response if response.is_a? String

    response
  end

end
