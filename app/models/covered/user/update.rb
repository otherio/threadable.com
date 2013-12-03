class Covered::User::Update < MethodObject

  def call user_record, attributes
    !!user_record.update_attributes(attributes)
  end

end
