class StripUserSpecificContentFromEmailMessageBody < MethodObject

  around = '##CovMid:\s?[a-zA-Z0-9+\/=-]+\s?##'
  REMOVE_CONTROLS_REGEXP = %r(#{around}.*?#{around})msu

  def call body
    @body = body.dup
    remove_unsubscribe_tokens!
    remove_controls!
    @body
  end

  def remove_unsubscribe_tokens!
    @body.gsub!(%r{(https?://(?:[\w\-]+\.)?covered\.io/[\w\-]+/unsubscribe)/(.+?)(?=<|")}mu) do
      url, token = $1, $2
      token =~ /=\n/ ? "#{url}=\n" : "#{url}"
    end

    @body.gsub!(%r{(https?://(?:[\w\-]+\.)?covered\.io/[\w\-]+/unsubscribe)/[\w=]+}mu) do
      $1
    end
  end

  def remove_controls!
    @body.gsub!(REMOVE_CONTROLS_REGEXP, '')
  end

end
