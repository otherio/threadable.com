class Serializer

  include Rails.application.routes.url_helpers

  class << self
    def serialize *args
      new(*args).serialize
    end
    alias_method :[], :serialize

    def plural_record_name
      name.split('::').last.sub(/Serializer\Z/,'').underscore.to_sym
    end

    def singular_record_name
      plural_record_name.to_s.singularize.to_sym
    end
  end

  def initialize object
    @object = object
  end
  attr_reader :object

  delegate :plural_record_name, :singular_record_name, to: :class

  def serialize
    if object.is_a? Array
      {plural_record_name => object.map(&method(:serialize_record)) }
    else
      {singular_record_name => serialize_record(object)}
    end
  end

  def serialize_record object
    raise "not implemented by subclass"
  end

end
