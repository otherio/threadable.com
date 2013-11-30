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

  def self.local_path
    Pathname("/storage/#{config[:local]}")
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
      service.directories.create(key: local_path.to_s)
    else
      service.directories.get(config[:bucket_name])
    end
  end

  def self.files
    directory.files
  end

  def self.pathname_for file
    local_root.join URI.decode(file.public_url)[1..-1]
  end

end
