require 'open-uri'
class Attachment < ActiveRecord::Base

  attr_accessible :url, :filename, :mimetype, :size, :writeable

  validates :url, :presence => true

  def content
    @content ||= open(url).read
  end

end
