class NewOrganization

  include Virtus
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  include ActiveModel::Conversion
  include ActiveModel::Validations
  define_model_callbacks :validation
  def persisted?; false; end

  def initialize controller, attributes={}
    @controller = controller
    remove_empty_members(attributes)
    super(attributes)
    if signed_in?
      self.your_name          = current_user.name
      self.your_email_address = current_user.email_address.to_s
    end
  end

  attr_reader :controller, :creator, :organization

  delegate :threadable, :current_user, :signed_in?, :sign_in!, to: :controller

  attribute :organization_name,       String
  attribute :email_address_username,  String
  attribute :your_name,               String
  attribute :your_email_address,      String
  attribute :password,                String
  attribute :password_confirmation,   String
  attribute :members,                 Array(NewOrganization::Member)

  validates_presence_of :organization_name
  validates_presence_of :email_address_username
  validates_presence_of :your_name,              unless: :signed_in?
  validates_presence_of :your_email_address,     unless: :signed_in?
  validates_presence_of :password,               unless: :signed_in?
  validates_presence_of :password_confirmation,  unless: :signed_in?

  validates_format_of :email_address_username, with: /\A[a-z0-9][\.a-z0-9_-]*[a-z0-9]\z/i, message: 'is invalid'
  validate :validate_uniqueness_of_your_email_address!,  unless: :signed_in?
  validate :validate_uniqueness_of_email_address_username!
  validate :validate_members!
  validate :validate_passwords_match!
  validates :password, presence: true, length: { minimum: 6, maximum: 128 }, confirmation: true, unless: :signed_in?

  def new_member
    NewOrganization::Member.new({})
  end

  def valid?
    run_callbacks(:validation){ super }
  end

  def create
    return true if @organization
    return false unless valid?

    if !signed_in?
      new_user = sign_up
      return false unless new_user.persisted?
      sign_in! new_user
    end

    @organization = threadable.organizations.create!(
      name: organization_name,
      email_address_username: email_address_username,
    )

    members.each do |member|
      @organization.members.add(
        name: member.name,
        email_address: member.email_address,
      )
    end

    true
  end

  private

  def sign_up
    threadable.sign_up(
      name:                  your_name,
      email_address:         your_email_address,
      confirm_email_address: true,
      password:              password,
      password_confirmation: password_confirmation,
    )
  end

  def remove_empty_members attributes
    Array(attributes[:members]).select! do |member|
      member[:name].present? || member[:email_address].present?
    end
  end

  def validate_uniqueness_of_your_email_address!
    errors.add(:your_email_address, 'is taken') if threadable.email_addresses.taken?(your_email_address)
  end

  def validate_uniqueness_of_email_address_username!
    threadable.organizations.find_by_email_address("#{email_address_username}@#{threadable.email_host}") or return
    errors.add(:email_address_username, 'is taken')
  end

  def validate_members!
    members.each(&:valid?)
    return if members.all?{|member| member.errors.blank? }
    errors.add(:base, 'some members are invalid')
  end

  def validate_passwords_match!
    password == password_confirmation and return
    errors.add(:password_confirmation, 'does not match password')
  end

end
