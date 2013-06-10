class Attachment < ActiveRecord::Base

  attr_accessible :url, :filename, :mimetype, :size, :writeable

  validates :url, :presence => true

  def content
    @content ||= Storage.read_url(url)
  end

end
