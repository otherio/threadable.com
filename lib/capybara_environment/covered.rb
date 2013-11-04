module CapybaraEnvironment::Covered

  def covered
    visit '/' if page.current_url.blank? || page.current_url == 'about:blank'
    uri = URI.parse(page.current_url)
    host, port = uri.host, uri.port
    @covered = nil if @covered && (@covered.host != host || @covered.port != port)
    @covered ||= Covered.new(host: host, port: port)
    binding.pry if @covered.nil?
    @covered
  end

end
