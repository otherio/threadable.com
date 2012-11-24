module Model

  extend ActiveSupport::Concern

  Invalid = Class.new(StandardError)

  module ClassMethods
    include ActiveModel::Naming

    def api_class
      "Api::#{name.pluralize}".constantize
    end

    def create! attributes
      new(attributes).save or raise Invalid
    end

    def all
      api_class.all.map{|attributes| new(attributes) }
    end

    def count
      api_class.count
    end

    def last
      new api_class.last
    end

  end

  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Virtus

  def persisted?
    id.present?
  end

  def new_record?
    !persisted?
  end

  def to_param
    id
  end

  def save
    return false unless valid?
    attributes = if persisted?
      self.class.api_class.update(as_json)
    else
      self.class.api_class.create(as_json)
    end
    self.attributes = attributes
    self
  end

  def update_attributes attributes
    self.attributes = attributes
    save
  end

  def destroy
    self.class.api_class.destroy(id)
  end

  def == other
    !self.id.nil? && other.class == self.class && self.id == other.id
  end
  alias_method :eql?, :==



end
