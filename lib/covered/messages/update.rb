class Covered::Messages::Update < Covered::Resource::Action

  option :id, required: true
  option :attributes, required: true

  def call
    covered.signed_in!
    message = resource.get(id: id)
    message.update_attributes(attributes)
    message
  end

end
