class Project < ActiveRecord::Base

  has_many :conversations, -> { order "updated_at DESC" }
  has_many :tasks, -> { order "position" }
  has_many :project_memberships
  has_many :memberships, class_name: 'ProjectMembership'
  has_many :members, :through => :project_memberships, :source => 'user' do
    def who_get_email
      where project_memberships: {gets_email:true}
    end
  end
  has_many :members_who_get_email, -> { where project_memberships: {gets_email:true} }, :through => :project_memberships, :source => 'user'
  has_many :events, -> { order "created_at" }

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_format_of :subject_tag, with: /\A[\w -]+\z/

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true

  def to_param
    slug
  end

  def subject_tag
    read_attribute(:subject_tag).presence || slug[0..6]
  end

  def email_address
    smtp_domain = Rails.application.config.action_mailer.smtp_settings[:domain]
    "#{slug}@#{smtp_domain}"
  end
  alias_method :email, :email_address

  def formatted_email_address
    "#{name} <#{email_address}>"
  end

end
