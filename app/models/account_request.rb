class AccountRequest < ActiveRecord::Base

  validates :organization_name, presence: true
  validates :email_address, presence: true, :email => true

  def confirm!
    return if confirmed?
    update_attribute :confirmed_at, Time.now
  end

  def confirmed?
    confirmed_at.present?
  end

end
