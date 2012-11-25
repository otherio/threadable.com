class Multify::User < Multify::Resource

  extend Multify::Resource::WithSlug

  class << self
    def authenticate params
      Integer( client.collection['authenticate'].post(params) )
    rescue RestClient::ResourceNotFound
      false
    end
  end

  assignable_attributes :name, :slug, :email, :password

  attribute :name,       String
  attribute :slug,       String
  attribute :email,      String
  attribute :password,   String
  attribute :created_at, Time
  attribute :updated_at, Time

  def projects
    Projects.new(user_id: id)
  end

  def assignable_attributes
    super.reject do |key, value|
      [:password, :slugt].include?(key) && (value.nil? || value == "")
    end
  end

end

require 'multify/user/projects'
