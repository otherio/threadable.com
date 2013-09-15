EmailProcessor::FooterFilterer = proc do |body|
  body.to_s.gsub(/##CovMid:\s?[\w\-=]+\s?##.*?##CovMid:\s?[\w\-=]+\s?##/ms, '')
end
