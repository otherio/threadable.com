class EnsureAllProjectsHaveAShortName < ActiveRecord::Migration

  def up

    Covered::Project.transaction do
      Covered::Project.find_in_batches do |projects|
        projects.each do |project|
          next if project.valid?
          project.short_name
          project.save!
        end
      end
    end

  end

  def down

  end

end
