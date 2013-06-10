class Attachment < ActiveRecord::Base

  attr_accessible :url, :filename, :mimetype, :size, :writeable

  validates :url, :presence => true

  def binary?
    MIME::Types[mimetype].first.try(:binary?)
  end

  def content
    @content ||= Storage.read_url(url, binary?)
  end

end
