class Serializer

  include Rails.application.routes.url_helpers

  class << self
    def plural_record_name
      @plural_record_name ||= name.split('::').last.sub(/Serializer\Z/,'').underscore.to_sym
    end
    attr_writer :plural_record_name

    def singular_record_name
      @singular_record_name ||= plural_record_name.to_s.singularize.to_sym
    end
    attr_writer :singular_record_name

    def serialize threadable, payload, options={}
      new(threadable, payload, options).as_json
    end
  end

  def initialize threadable, payload, options={}
    @threadable, @payload, @options = threadable, payload, options
  end
  attr_reader :threadable, :payload, :options
  delegate :current_user, to: :threadable
  delegate :plural_record_name, :singular_record_name, to: :class

  def as_json
    if payload.is_a? Array
      {plural_record_name => payload.map(&method(:serialize_record)) }
    else
      {singular_record_name => serialize_record(payload)}
    end
  end

  def serializer type=nil
    type ? self.class.parent.const_get("#{type.to_s.camelize}Serializer", true) : self.class
  end

  def serialize type=nil, payload
    serializer(type).serialize(threadable, payload).values.first
  end

  def serialize_record record
    raise "not implemented by subclass"
  end

end
