EmailProcessor::FooterFilterer = proc do |body|
  # body = body.to_s.gsub(%r{(https?://(?:[\w\-]+\.)?covered\.io/[\w\-]+/unsubscribe)/(.+?)(?=<|")}m) do
  #   url, token = $1, $2
  #   token =~ /=\n/ ? "#{url}=\n" : "#{url}"
  # end

  # body.to_s.gsub(%r{(https?://(?:[\w\-]+\.)?covered\.io/[\w\-]+/unsubscribe)/[\w=]+}m) do
  #   $1
  # end
  body
end
