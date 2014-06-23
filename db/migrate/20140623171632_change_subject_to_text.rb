class ChangeSubjectToText < ActiveRecord::Migration
  def change
    change_column :conversations, :subject, :text
    change_column :messages, :subject, :text
  end
end
