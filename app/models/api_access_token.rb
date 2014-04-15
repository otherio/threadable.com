class ApiAccessToken < ActiveRecord::Base

  belongs_to :user

  validates :user_id, presence: true
  validates :token, presence: true, uniqueness: true

  scope :active, -> { where active: true }

  def token
    read_attribute(:token) or write_attribute(:token, SecureRandom.hex)
  end

  def deactivate!
    update! active: false
  end

end
