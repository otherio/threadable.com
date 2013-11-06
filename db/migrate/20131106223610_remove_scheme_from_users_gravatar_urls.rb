class RemoveSchemeFromUsersGravatarUrls < ActiveRecord::Migration
  def change

    Covered::User.transaction do
      Covered::User.select(:avatar_url).find_in_batches do |users|

        users.each do |user|
          if user.avatar_url =~ %r{^http://gravatar\.com/(.+)$}
            user.update_attribute(:avatar_url, "//gravatar.com/#{$1}")
          end
        end

      end
    end

  end
end
