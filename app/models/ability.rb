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
        can :be_google_user_for,          Threadable::Organization

        can :set_google_sync_for,         Threadable::Group
        can :change_settings_for,         Threadable::Group

        can :create,                      Threadable::Group::Members
        can :delete,                      Threadable::Group::Members
      when :member
        if user.organization.settings.group_membership_permission == :member
          can [:create, :delete], Threadable::Group::Members
        end

        if user.organization.settings.group_settings_permission == :member
          can :change_settings_for, Threadable::Group
        end

      end
    when Threadable::Group::Member

      # TBD

    end

  end
end
