class Attachment < ActiveRecord::Base

  validates :url, :presence => true

  def binary?
    MIME::Types[mimetype].first.try(:binary?)
  end

  def content
    @content ||= HTTParty.get(url)
  end

end
