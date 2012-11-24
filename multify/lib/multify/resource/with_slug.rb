module Multify::Resource::WithSlug

  def find_by_slug slug
    success, members = client.find(slug: slug)
    new members.first if success && members.length > 0
  end

end
