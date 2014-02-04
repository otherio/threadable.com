class StripThreadableContentFromEmailMessageBody < MethodObject

  around = '##CovMid:\s?[a-zA-Z0-9+\/=-]+\s?##'
  REMOVE_CONTROLS_REGEXP = %r(#{around}.*?#{around})msu

  # http://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags/1732454#1732454
  REMOVE_OPEN_TRACKER_REGEXP = %r{\<img width="1px" height="1px" alt="" src="http://email\.(staging\.|)threadable.com/[^>]+">}msu

  def call body
    @body = body.dup
    remove_unsubscribe_tokens!
    remove_controls!
    remove_open_tracker!
    @body
  end

  def remove_unsubscribe_tokens!
    @body.gsub!(%r{(https?://(?:[\w\-]+\.)?(threadable\.com|covered\.io)/[\w\-]+/unsubscribe)/(.+?)(?=<|")}mu) do
      url, token = $1, $2
      token =~ /=\n/ ? "#{url}=\n" : "#{url}"
    end

    @body.gsub!(%r{(https?://(?:[\w\-]+\.)?(threadable\.com|covered\.io)/[\w\-]+/unsubscribe)/[\w=]+}mu) do
      $1
    end
  end

  def remove_controls!
    @body.gsub!(REMOVE_CONTROLS_REGEXP, '')
  end

  def remove_open_tracker!
    @body.gsub!(REMOVE_OPEN_TRACKER_REGEXP, '')
  end

end
