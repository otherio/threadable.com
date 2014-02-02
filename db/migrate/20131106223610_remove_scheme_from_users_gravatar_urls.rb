class RemoveSchemeFromUsersGravatarUrls < ActiveRecord::Migration

  def up

    Threadable::User.transaction do
      Threadable::User.select(:id, :avatar_url).find_in_batches do |users|
        users.each do |user|
          if user.avatar_url =~ %r{^http://gravatar\.com/(.+)$}
            user.update_attribute(:avatar_url, "//gravatar.com/#{$1}")
          end
        end
      end
    end

  end

  def down

    Threadable::User.transaction do
      Threadable::User.select(:id, :avatar_url).find_in_batches do |users|
        users.each do |user|
          if user.avatar_url =~ %r{^//gravatar\.com/(.+)$}
            user.update_attribute(:avatar_url, "http://gravatar.com/#{$1}")
          end
        end
      end
    end

  end

end
