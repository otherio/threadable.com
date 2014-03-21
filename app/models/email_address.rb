class EmailAddress < ActiveRecord::Base

  def self.normalize address
    address.to_s.downcase.strip_non_ascii
  end
  delegate :normalize, to: :class

  belongs_to :user

  validates :address, :presence => true, :email => true
  validates_uniqueness_of :address
  validate :ensure_only_one_primary, if: :primary?

  before_save do |record|
    return false if !record.new_record? && record.address_changed?
  end

  scope :primary,   -> { where(primary: true) }
  scope :confirmed, -> { where('email_addresses.confirmed_at IS NOT NULL') }
  scope :unconfirmed, -> { where('email_addresses.confirmed_at IS NULL') }

  scope :for_user, ->(user){
    user_id = Integer === user ? user : user.id
    where(user_id: user_id)
  }
  scope :address_not, ->(address){
    where(arel_table[:address].not_eq(address))
  }

  scope :address, ->(addresses){
    where(address: Array(addresses).map{|a| normalize(a) })
  }

  def confirmed?
    !confirmed_at.nil?
  end

  def address
    normalize read_attribute(:address)
  end

  def address= address
    write_attribute(:address, normalize(address))
  end

  def has_taken_error?
    errors[:address].present? && errors[:address].include?(I18n.t('errors.messages.taken'))
  end

  private

  def ensure_only_one_primary
    if user_id && self.class.for_user(user_id).where(primary: true).address_not(self.address).present?
      errors.add(:base, 'there can be only one primary email address')
    end
  end

end
