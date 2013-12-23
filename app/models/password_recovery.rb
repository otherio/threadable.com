class PasswordRecovery

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  def persisted?; false; end
  include Virtus

  attribute :email, String

  def == other
    attributes == other.attributes
  end
  alias_method :eql?, :==

end
