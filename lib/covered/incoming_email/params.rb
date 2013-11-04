module Covered::IncomingEmail::Params

  CODER = ::ActiveRecord::Coders::YAMLColumn.new(Hash)

  def self.dump(params)
    CODER.dump(encode_attachments!(params.dup))
  end

  def self.load(encoded_params)
    decode_attachments!(CODER.load(encoded_params))
  end

  def self.encode_attachments!(params)
    update_attachments(params, &method(:encode_attachment))
  end

  def self.encode_attachment(attachment)
    attachment.seek(0) if attachment.respond_to? :seek
    {
      "original_filename" => attachment.original_filename,
      "content_type" => attachment.content_type,
      "read" => attachment.read,
    }
  end

  def self.decode_attachments!(params)
    update_attachments(params, &method(:decode_attachment))
  end

  File = Struct.new(:original_filename, :content_type, :read)
  def self.decode_attachment(attachment)
    self::File.new *attachment.values_at("original_filename", "content_type", "read")
  end

  def self.update_attachments(params, &block)
    1.upto(params['attachment-count'].to_i).each do |n|
      params["attachment-#{n}"] = block.call(params.fetch("attachment-#{n}"))
    end
    params
  end

end
