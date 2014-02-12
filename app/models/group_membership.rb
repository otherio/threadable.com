class GroupMembership < ActiveRecord::Base

  belongs_to :group
  belongs_to :user
  has_one :organization, through: :group

  validates_uniqueness_of :user_id, scope: :group_id, message: "already a member of group"

  scope :for_organization, -> organization_id {
    joins(:organization).where(groups:{ organization_id: organization_id })
  }

  scope :who_get_summaries, -> {
    where(summary: true)
  }

end
