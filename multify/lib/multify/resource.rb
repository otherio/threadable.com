class Multify::Resource

  include Virtus

  NotFound = Class.new(StandardError)
  Error = Class.new(StandardError)

  class << self

    def client
      @client ||= begin
        name = self.name.split('::').last.downcase+'s'
        Multify::Resource::Client.new(Multify.host + name)
      end
    end

    def assignable_attributes *attributes
      @attributes ||= []
      @attributes += attributes
      @attributes
    end

    def find params={}
      if params[:id]
        member = new(id: params[:id])
        member.reload or raise NotFound, params.inspect
        member
      else
        success, members = client.find(params)
        success or raise Error, members.inspect
        return members.map{|member| new member }
      end
    end

    def all
      find
    end

    def create attributes
      member = new(attributes)
      member.save
      member
    end

  end

  attribute :id, Integer

  def errors
    @errors || []
  end

  def assignable_attributes
    attributes.clone.reject do |key, _|
      !self.class.assignable_attributes.include?(key)
    end
  end

  def persisted?
    !new_record?
  end

  def new_record?
    id.nil?
  end

  def save
    success, attributes = persisted? ?
      self.class.client.update(id, assignable_attributes) :
      self.class.client.create(assignable_attributes)
    if success
      self.attributes = attributes
      true
    else
      @errors = attributes
      false
    end
  end

  def reload
    return false unless persisted?
    success, attributes = self.class.client.read(id)
    if success
      self.attributes = attributes
      true
    else
      @errors = attributes
      false
    end
  end

  def update attributes
    self.attributes = attributes
    self
  end

  def delete
    return false unless persisted?
    self.class.client.delete(id).first
  end

  def == other
    !id.nil? && self.class == other.class && id == other.id
  end
  alias_method :eql?, :==

end

require "multify/resource/client"
require "multify/resource/has_many"
require "multify/resource/with_slug"
