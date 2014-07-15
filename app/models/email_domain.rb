class EmailDomain < ActiveRecord::Base

  def self.normalize domain
    domain.to_s.downcase.strip_non_ascii
  end
  delegate :normalize, to: :class

  belongs_to :organization

  validates :domain, :presence => true
  validates_uniqueness_of :domain
  validate :ensure_domain_is_a_domain
  validate :ensure_only_one_outgoing, if: :outgoing?

  before_save do |record|
    return false if !record.new_record? && record.domain_changed?
  end

  scope :outgoing,   -> { where(outgoing: true) }

  scope :for_organization, ->(organization){
    organization_id = Integer === organization ? organization : organization.id
    where(organization_id: organization_id)
  }
  scope :domain, ->(domain){
    where(arel_table[:domain].eq(domain))
  }
  scope :domain_not, ->(domain){
    where(arel_table[:domain].not_eq(domain))
  }

  private

  def ensure_only_one_outgoing
    if organization_id && self.class.for_organization(organization_id).where(outgoing: true).domain_not(self.domain).present?
      errors.add(:base, 'there can be only one outgoing domain')
    end
  end

  def ensure_domain_is_a_domain
    if domain !~ /^(?:[a-zA-Z0-9]+(?:\-*[a-zA-Z0-9])*\.)+[a-zA-Z]{2,63}$/ && domain != 'localhost'
      errors.add(:domain, 'is invalid')
    end
  end

end
