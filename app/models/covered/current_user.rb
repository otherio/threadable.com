require 'covered/user'

class Covered::CurrentUser < Covered::User

  autoload :EmailAddresses
  autoload :EmailAddress
  autoload :Projects
  autoload :Project
  autoload :Messages
  autoload :Message

  def initialize covered, user_id
    @covered, @user_id = covered, user_id
  end
  attr_reader :covered, :user_id

  alias_method :id, :user_id

  def user_record
    @user_record ||= ::User.find(@user_id)
  end

  def projects
    @projects ||= Projects.new(self)
  end

  def messages
    @messages ||= Messages.new(self)
  end

  def email_addresses
    @email_addresses ||= EmailAddresses.new(self)
  end

  def email_address
    email_addresses.primary.try(:address)
  end

  def requires_setup?
    !web_enabled?
  end

  def confirm!
    !!update(confirmed_at: Time.now)
  end

  def confirmed?
    user_record.confirmed_at.present?
  end

  def update attributes
    !!user_record.update_attributes(attributes)
  end

  def update! attributes
    update(attributes)
    user_record.errors.empty? or
    raise Covered::RecordInvalid, "User invalid: #{user_record.errors.full_messages.to_sentence}"
  end

end
