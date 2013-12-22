class AddSubjectTagToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :subject_tag, :string
  end
end
