class Multify::User < Multify::Resource

  class << self
    def authenticate params
      Integer( client.collection['authenticate'].post(params) )
    rescue RestClient::ResourceNotFound
      false
    end
  end

  assignable_attributes :name, :email, :password

  attribute :name,       String
  attribute :email,      String
  attribute :password,   String
  attribute :created_at, Time
  attribute :updated_at, Time

  def projects
    Projects.new(user_id: id)
  end

  def assignable_attributes
    super.reject do |key, value|
      key == :password && value.nil?
    end
  end

end

require 'multify/user/projects'
