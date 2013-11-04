module Covered

  @config = Hash.new do |config, name|
    if name.is_a? String
      config[name] = begin
        config = Rails.root.join("config/#{name}.yml").read
        config = ERB.new(config).result
        config = YAML.load(config)
        config.has_key?(Rails.env) ? config[Rails.env] : config
      end
    else
      config[String(name)]
    end
  end

  def self.config name
    @config[name]
  end

end
