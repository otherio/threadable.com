class AddSubjectTagToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :subject_tag, :string

    Group.all.each do |group|
      group.update_attribute(:subject_tag, "#{group.organization.subject_tag}+#{group.email_address_tag}")
    end
  end

  def down
    remove_column :groups, :subject_tag
  end
end
