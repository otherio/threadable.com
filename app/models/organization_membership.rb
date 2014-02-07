class OrganizationMembership < ActiveRecord::Base

  DELIVERY_METHODS = Threadable::DELIVERY_METHODS

  belongs_to :organization
  belongs_to :user
  has_many :email_addresses, through: :user

  scope :who_get_email, ->{ where(gets_email: true) }

  scope :with_ungrouped_delivery_methods, ->(delivery_methods){
    delivery_methods = delivery_methods.map{|delivery_method| DELIVERY_METHODS.index(delivery_method) }
    where(ungrouped_delivery_method: delivery_methods)
  }

  validates_presence_of :organization_id, :user_id
  validates_inclusion_of :gets_email, :in => [ true, false ]
  validates_inclusion_of :ungrouped_delivery_method, :in => DELIVERY_METHODS

  def subscribed?
    gets_email?
  end

  def subscribe!
    update! gets_email: true
  end

  def unsubscribe!
    update! gets_email: false
  end

  def ungrouped_delivery_method
    index = read_attribute(:ungrouped_delivery_method)
    DELIVERY_METHODS[index]
  end

  def ungrouped_delivery_method= delivery_method
    index = DELIVERY_METHODS.index(delivery_method) or raise ArgumentError, "invalid delivery method: #{delivery_method.inspect}"
    write_attribute(:ungrouped_delivery_method, index)
  end

end
