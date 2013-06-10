EmailProcessor::UnsubscribeTokenFilterer = proc do |body|
  body.to_s.gsub(%r{(https?://[\w\-\.]*multifyapp\.com/[\w\-\.]+/unsubscribe)/[\w=]+}m, '\1')
end
