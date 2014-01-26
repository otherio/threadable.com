class SentEmail < ActiveRecord::Base
  def relayed?
    !! relayed_at
  end

  def relayed!
    update_attribute(:relayed_at, Time.now)
  end
end
