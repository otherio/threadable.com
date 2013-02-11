module ApplicationHelper

  def avatar_url(user, size=24)
    if user.avatar_url.present?
      user.avatar_url
    else
      default_url = "#{root_url}images/guest.png"
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      # change this when we have a default image other than gravatar's
      #"http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_url)}"
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    end
  end

end


