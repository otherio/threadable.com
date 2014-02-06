class Threadable::Groups < Threadable::Collection

  def all
    groups_for scope
  end

  # THIS SHOULD BE DEPRICATED
  def my
    groups_for scope.joins(:group_members).where(group_memberships:{ user_id: threadable.current_user_id })
  end

  def find_by_ids ids
    groups_for (scope.find(ids) or return)
  end

  def find_by_ids! ids
    find_by_ids(ids) or raise Threadable::RecordNotFound, "unable to find groups with ids #{ids.inspect}"
  end

  def find_by_id id
    groups_for (scope.find(id) or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find group with id #{id.inspect}"
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Threadable::RecordNotFound, "unable to find group with slug #{slug.inspect}"
  end

  def auto_joinable
    groups_for scope.where(auto_join: true)
  end

  def find_by_email_address_tag email_address_tag
    group_for (scope.where(email_address_tag: email_address_tag.downcase).first or return)
  end
  alias_method :find_by_slug, :find_by_email_address_tag

  def find_by_email_address_tag! email_address_tag
    find_by_email_address_tag(email_address_tag) or raise Threadable::RecordNotFound, "unable to find group with email address tag #{email_address_tag.inspect}"
  end

  def find_by_email_address_tags email_address_tags
    email_address_tags = email_address_tags.map(&:downcase)
    group_records = scope.where('email_address_tag in (?)', email_address_tags).to_a
    email_address_tags.map do |email_address_tag|
      group_for group_records.find{|group| group.email_address_tag == email_address_tag}
    end
  end

  def find_by_email_address_tags! email_address_tags
    groups = find_by_email_address_tags(email_address_tags)
    groups.all? or raise Threadable::RecordNotFound, "unable to find all groups with email address tags #{email_address_tags.inspect}"
    groups
  end

  def include? group
    !!scope.where(id: group.group_id).exists?
  end

  def empty?
    count == 0
  end

  private

  def scope
    ::Group.all
  end

  def group_for group_record
    Threadable::Group.new(threadable, group_record) if group_record
  end

  def groups_for group_records
    group_records.map{ |group_record| group_for group_record }
  end

end
