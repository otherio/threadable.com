class EnsureAllOrganizationsHaveAShortName < ActiveRecord::Migration

  def up

    Threadable::Organization.transaction do
      Threadable::Organization.find_in_batches do |organizations|
        organizations.each do |organization|
          next if organization.valid?
          organization.short_name
          organization.save!
        end
      end
    end

  end

  def down

  end

end
