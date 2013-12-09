module HTTMultiParty::Multipartable

  def body_with_force_array=(value)
    self.body_without_force_array = Array(value)
  end

  alias_method_chain :body=, :force_array

end
