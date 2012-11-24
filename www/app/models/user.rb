class User

  include Model

  def self.find_by_id *args
    new Api::Users.find_by_id(*args)
  end

  def self.find_by_email *args
    new Api::Users.find_by_email(*args)
  end

  attribute :id, Integer
  attribute :name, String
  attribute :slug, String
  attribute :email, String
  attribute :password, String

end
