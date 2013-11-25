require 'spec_helper'

describe Covered::Config do

  it "loads the config of the given key" do
    expect(Covered::Config[:database]).to be_a Hash
    expect(Covered::Config[:database]).to eq load_config(:database)
  end

  def load_config name
    config = Rails.root.join("config/#{name}.yml").read
    config = ERB.new(config).result
    config = YAML.load(config)
    config.has_key?(Rails.env) ? config[Rails.env] : config
  end
end
