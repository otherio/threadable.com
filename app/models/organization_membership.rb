class OrganizationMembership < ActiveRecord::Base

  belongs_to :organization
  belongs_to :user
  has_many :email_addresses, through: :user

  scope :who_get_email, ->{ where(gets_email: true) }

  validates_inclusion_of :gets_email, :in => [ true, false ]

  def subscribed?
    gets_email?
  end

  def subscribe!
    update! gets_email: true
  end

  def unsubscribe!
    update! gets_email: false
  end

end
