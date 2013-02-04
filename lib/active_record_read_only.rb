require 'ostruct'

class ActiveRecord::Base

  def to_read_only_object(options={})
    OpenStruct.new(as_json(options))
  end

end
