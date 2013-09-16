module Covered::Config

  @config = {}
  def self.[] name
    @config[name.to_sym] ||= begin
      config = Rails.root.join("config/#{name}.yml").read
      config = ERB.new(config).result
      config = YAML.load(config)
      config.has_key?(Rails.env) ? config[Rails.env] : config
    end
  end

end
