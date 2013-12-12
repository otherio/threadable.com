class EmailAddress < ActiveRecord::Base

  belongs_to :user

  validates :address, :presence => true, :email => true
  validates_uniqueness_of :address
  validate :ensure_only_one_primary, if: :primary?

  before_save do |record|
    return false if !record.new_record? && record.address_changed?
  end

  def self.primary
    where(primary: true)
  end

  def address= address
    write_attribute(:address, address.try(:strip_non_ascii))
  end

  scope :for_user, ->(user){
    where(user_id: user.is_a?(User) ? user.id : user)
  }
  scope :address_not, ->(address){
    where(arel_table[:address].not_eq(address))
  }

  def has_taken_error?
    errors[:address].present? && errors[:address].include?(I18n.t('errors.messages.taken'))
  end

  private

  def ensure_only_one_primary
    if self.class.for_user(user_id).where(primary: true).address_not(self.address).present?
      errors.add(:base, 'there can be only one primary email address')
    end
  end

end
