# See the wiki for details:
# https://github.com/ryanb/cancan/wiki/Defining-Abilities
class Ability
  include ::CanCan::Ability

  def initialize(user)

    case user
    when Threadable::Organization::Member

      case user.role
      when :owner
        can :remove_member_from,          Threadable::Organization
        can :make_owners_for,             Threadable::Organization
        can :change_settings_for,         Threadable::Organization
        can :remove_non_empty_group_from, Threadable::Organization
        can :set_google_sync_for,         Threadable::Group
        can :be_google_user_for,          Threadable::Organization
      when :member

      end
    when Threadable::Group::Member

      # TBD

    end

  end
end
