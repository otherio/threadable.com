class Authentication

  include Virtus
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :email
  attribute :password

  def persisted?
    false
  end

end
