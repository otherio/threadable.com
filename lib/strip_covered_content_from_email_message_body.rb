class StripCoveredContentFromEmailMessageBody < MethodObject

  around = '##CovMid:\s?[a-zA-Z0-9+\/=-]+\s?##'
  REMOVE_CONTROLS_REGEXP = %r(#{around}.*?#{around})msu
  REMOVE_EMAIL_BUTTON_TIPS_REGEXP = %r(-- tip: control covered by putting commands in your reply, just like this:\n?)msu
  REMOVE_EMAIL_BUTTON_REF_REGEXP = %r(-- don't delete this: \[ref: .*\]\n?)msu

  def call body
    @body = body.dup
    remove_unsubscribe_tokens!
    remove_controls!
    remove_email_button_cruft!
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

  def remove_email_button_cruft!
    @body.gsub!(REMOVE_EMAIL_BUTTON_TIPS_REGEXP, '')
    @body.gsub!(REMOVE_EMAIL_BUTTON_REF_REGEXP, '')
  end

end
