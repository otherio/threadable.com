require 'open-uri'

module Storage

  def self.config
    Rails.application.config.storage
  end

  def self.local?
    config.has_key? :local
  end

  def self.local_root
    @local_root ||= Rails.root.join('public')
  end

  def self.service
    @service ||= if local?
      Fog::Storage.new({
        :provider   => 'Local',
        :local_root => local_root.tap(&:mkpath),
        :endpoint   => "/",
      })
    else
      Fog::Storage.new(
        :provider              => 'AWS',
        :aws_access_key_id     => config[:s3_access_key_id],
        :aws_secret_access_key => config[:s3_secret_access_key],
      )
    end
  end

  def self.directory
    @directory ||= if local?
      service.directories.create(key: "storage/#{config[:local]}")
    else
      service.directories.get(config[:bucket_name])
    end
  end

  def self.files
    directory.files
  end

  def self.url_prefix
    File.join(service.endpoint, directory.key)
  end

  # this is here to support reading urls from local storage in development and test
  def self.read_url(url, binary=false)
    if url.to_s.start_with?(url_prefix)
      files.get(url.sub(url_prefix, '')).body
    else
      open(url).read
    end
  end

end
