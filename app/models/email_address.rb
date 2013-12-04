class EmailAddress < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :address, :user
  validates_uniqueness_of :address

  validate :ensure_only_one_primary, if: :primary?

  validates_format_of :address,
    with: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/,
    allow_blank: true,
    if: :address_changed?

  def self.primary
    where(primary: true)
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
