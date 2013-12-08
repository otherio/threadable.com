class Attachment < ActiveRecord::Base

  validates :url, :presence => true

  def binary?
    MIME::Types[mimetype].first.try(:binary?)
  end

  def content
    @content ||=  if url[0] == '/'
      Rails.root.join('public', url[1..-1]).read
    else
      HTTParty.get(url)
    end
  end

end
