class Api::DoersSerializer < Api::MembersSerializer
  def singular_record_name
    "doer"
  end
end
