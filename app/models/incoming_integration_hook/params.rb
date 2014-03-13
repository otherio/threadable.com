module IncomingIntegrationHook::Params
  CODER = ::ActiveRecord::Coders::YAMLColumn.new(Hash)

  def self.dump(params)
    CODER.dump(params.dup)
  end

  def self.load(encoded_params)
    CODER.load(encoded_params)
  end

end
