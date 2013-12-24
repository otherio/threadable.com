class EmailValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    return if ValidateEmailAddress.call(value)
    record.errors[attribute] << (options[:message] || "is invalid")
  end
end
