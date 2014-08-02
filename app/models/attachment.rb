class Attachment < ActiveRecord::Base

  class FakeParser
    def self.call(body, format)
      body
    end
  end

  validates :url, :presence => true

  def binary?
    MIME::Types[mimetype].first.try(:binary?)
  end

  def content
    @content ||=  if url[0] == '/'
      Rails.root.join('public', URI.unescape(url[1..-1])).read
    else
      HTTParty.get(url, parser: FakeParser)
    end
  end

end
