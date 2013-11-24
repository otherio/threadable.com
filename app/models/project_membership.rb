class ProjectMembership < ActiveRecord::Base

  belongs_to :project
  belongs_to :user

  scope :that_get_email, ->{ where(gets_email: true) }

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
