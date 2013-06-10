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

  def self.connection
    @connection ||= if local?
      Fog::Storage.new({
        :provider   => 'Local',
        :local_root => local_root.tap(&:mkpath),
        :endpoint   => "http://localhost:3000/",
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
      connection.directories.create(key: "storage/#{config[:local]}")
    else
      connection.directories.get(config[:bucket_name])
    end
  end

  def self.put(key, body)
    directory.files.create(key: key, body: body, public: true)
  end

  def self.get(key)
    directory.files.get(key)
  end

  # this is here to support reading urls from local storage in development and test
  def self.read_url(url, binary=false)
    if local? && url.include?(connection.endpoint)
      path = local_root.join(URI.parse(url).path[1..-1])
      binary ? File.binread(path) : File.read(path)
    else
      open(url).read
    end
  end

end
