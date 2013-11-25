module Covered::Config

  def self.to_hash
    @hash ||= Hash.new do |config, name|
      if name.is_a? String
        config[name] = load name
      else
        config[String(name)]
      end
    end
  end

  def self.[] name
    to_hash[name]
  end

  def self.load name
    config = Rails.root.join("config/#{name}.yml").read
    config = ERB.new(config).result
    config = YAML.load(config)
    config.has_key?(Rails.env) ? config[Rails.env] : config
  end

end
