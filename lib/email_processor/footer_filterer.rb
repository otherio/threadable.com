EmailProcessor::FooterFilterer = proc do |body|
  body.to_s.gsub(/##CovMid: \w+ ##.*?##CovMid: \w+ ##/ms, '')
end
