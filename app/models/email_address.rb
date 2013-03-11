class EmailAddress < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :address, :user
  validates_uniqueness_of :address

  validate :ensure_only_one_primary, if: :primary?

  validates_format_of :address,
    with: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/,
    allow_blank: true,
    if: :address_changed?

  attr_accessible :user, :address, :primary

  scope :primary, where(primary: true)
  scope :for_user, ->(user){
    where(user_id: user.is_a?(User) ? user.id : user)
  }
  scope :address_not, ->(address){
    where(EmailAddress.arel_table[:address].not_eq(address))
  }

  def has_taken_error?
    errors[:address].present? && errors[:address].include?(I18n.t('activerecord.errors.messages.taken'))
  end

  private

  def ensure_only_one_primary
    if EmailAddress.primary.for_user(user_id).address_not(self.address).present?
      errors.add(:base, 'there can be only one primary email address')
    end
  end

end
