class GroupMembership < ActiveRecord::Base

  # you can add to the end of this, but do not reorder it.
  enum delivery_method: [:gets_each_message, :gets_in_summary, :gets_first_message]

  belongs_to :group
  belongs_to :user
  has_one :organization, through: :group

  validates_uniqueness_of :user_id, scope: :group_id, message: "already a member of group"

  scope :for_organization, -> organization_id {
    joins(:organization).where(groups:{ organization_id: organization_id })
  }

end
