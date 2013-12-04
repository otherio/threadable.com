class Covered::IncomingEmail::Creator < Covered::User

  def initialize incoming_email
    @incoming_email = incoming_email
  end
  attr_reader :incoming_email
  delegate :covered, to: :incoming_email

  def user_record
    @user_record ||= ::User.find(incoming_email.creator_id)
  end

end
