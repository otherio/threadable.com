module Model

  extend ActiveSupport::Concern

  module ClassMethods
    include ActiveModel::Naming

    def api_class
      "Api::#{name.pluralize}".constantize
    end

  end

  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Virtus

  def persisted?
    id.present?
  end

  def to_param
    id
  end

  def save
    attributes = if persisted?
      self.class.api_class.update(as_json)
    else
      self.class.api_class.create(as_json)
    end
    self.attributes = attributes
    self
  end

  def == other
    !self.id.nil? && self.id == other.id
  end

end
