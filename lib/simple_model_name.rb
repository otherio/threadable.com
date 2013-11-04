module SimpleModelName
  def model_name model_name=nil
    @_model_name = nil if model_name.present?
    @_model_name ||= ActiveModel::Name.new(self, nil, model_name || name.split('::').last)
  end
end
