class AddSubjectTagToOrganizations < ActiveRecord::Migration
  def change
    add_column :projects, :subject_tag, :string
  end
end
