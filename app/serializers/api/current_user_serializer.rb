# FYI: this is a special case and should not be an example of how to make a serializer - Jared
class Api::CurrentUserSerializer < Serializer

  def self.serialize covered, _
    new(covered).as_json
  end

  def initialize covered
    @covered = covered
  end
  attr_reader :covered
  delegate :current_user, to: :covered

  def as_json
    if current_user
      {
        user: {
          id:            'current',
          user_id:       current_user.user_id,
          param:         current_user.to_param,
          name:          current_user.name,
          email_address: current_user.email_address.to_s,
          slug:          current_user.slug,
          avatar_url:    current_user.avatar_url,
          organizations: serialize(:organizations, current_user.organizations.all),
        }
      }
    else
      {
        user: {
          id:            'current',
          user_id:       nil,
          param:         nil,
          name:          nil,
          email_address: nil,
          slug:          nil,
          avatar_url:    nil,
          organizations: [],
        }
      }
    end
  end

end
