class Covered::Project < ActiveRecord::Base

  extend SimpleModelName

  has_many :conversations, -> { order "updated_at DESC" }
  has_many :messages, through: :conversations
  has_many :tasks, -> { order "position" }, class_name: 'Covered::Task'
  has_many :project_memberships
  has_many :memberships, class_name: 'ProjectMembership'
  has_many :members, :through => :project_memberships, :source => 'user' do
    def who_get_email
      where project_memberships: {gets_email:true}
    end
  end
  has_many :members_who_get_email, -> { where project_memberships: {gets_email:true} }, :through => :project_memberships, :source => 'user'
  has_many :events, -> { order "created_at" }

  scope :with_members, ->{ includes(:project_memberships).where('project_memberships.id IS NOT NULL').references(:project_memberships) }
  scope :without_members, ->{ includes(:project_memberships).where(project_memberships:{id:nil}).references(:project_memberships) }


  validates_presence_of :name, :slug, :email_address_username
  validates_uniqueness_of :name, :slug
  validates_format_of :subject_tag, with: /\A[\w -]+\z/

  acts_as_url :short_name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true

  def name= name
    self.short_name = name if short_name.blank?
    super
  end

  def short_name
    self.short_name = name if subject_tag.blank?
    subject_tag
  end

  def short_name= short_name
    short_name = short_name.presence || name
    return if short_name.blank?
    short_name = short_name.gsub(/[\W]+/, ' ').strip
    self.subject_tag = short_name
    self.slug = nil
    self.email_address_username = short_name.downcase.gsub(/\W+/,'.')
  end

  def to_param
    slug
  end

  def email_address
    smtp_domain = Rails.application.config.action_mailer.smtp_settings[:domain]
    "#{email_address_username}@#{smtp_domain}"
  end
  alias_method :email, :email_address

  def formatted_email_address
    "#{name} <#{email_address}>"
  end

  def list_id
    smtp_domain = Rails.application.config.action_mailer.smtp_settings[:domain]
    "#{email_address_username}.#{smtp_domain}"
  end

  def formatted_list_id
    "#{name} <#{list_id}>"
  end

end
