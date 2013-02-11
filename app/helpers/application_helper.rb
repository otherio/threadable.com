module ApplicationHelper

  def default_avatar_url
    URI.join(root_url, 'images/default-avatar.png').to_s
  end

  def avatar_url(user, size=24)
    return default_avatar_url unless user.present?
    return user.avatar_url if user.avatar_url.present?
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    # change this when we have a default image other than gravatar's
    #"http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_avatar_url)}"
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end

end


