class Covered::User::EmailAddresses

  def initialize current_user
    @current_user = current_user
  end
  attr_reader :current_user
  delegate :covered, to: :current_user

  def all
    scope.select(&:persisted?).map{|email_address_record| email_address_for email_address_record }
  end

  def primary
    email_address_for (scope.primary or return)
  end

  def add email_address, primary=false
    scope.transaction do
      scope.update_all(primary: false) if primary
      email_address_for scope.create(address: email_address, primary: primary)
    end
  end

  def add! email_address, primary=false
    email_address = add(email_address, primary)
    email_address.persisted? or raise Covered::RecordInvalid, "user email address invalid: #{email_address.errors.full_messages.to_sentence}"
    email_address
  end


  def inspect
    %(#<#{self.class} current_user_id: #{current_user.id}>)
  end

  private

  def scope
    current_user.user_record.email_addresses
  end

  def email_address_for email_address_record
    Covered::User::EmailAddress.new(current_user, email_address_record)
  end

end
