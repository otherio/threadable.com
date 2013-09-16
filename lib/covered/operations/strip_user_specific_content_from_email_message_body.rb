class Covered::Operations::StripUserSpecificContentFromEmailMessageBody < Covered::Operation

  require_option :body

  def call
    @body = @body.to_s.dup
    remove_unsubscribe_tokens!
    remove_footers!
    @body
  end

  def remove_unsubscribe_tokens!
    @body.gsub!(%r{(https?://(?:[\w\-]+\.)?covered\.io/[\w\-]+/unsubscribe)/(.+?)(?=<|")}m) do
      url, token = $1, $2
      token =~ /=\n/ ? "#{url}=\n" : "#{url}"
    end

    @body.gsub!(%r{(https?://(?:[\w\-]+\.)?covered\.io/[\w\-]+/unsubscribe)/[\w=]+}m) do
      $1
    end
  end

  def remove_footers!
    @body.gsub!(/##CovMid:\s?[\w\-=]+\s?##.*?##CovMid:\s?[\w\-=]+\s?##/ms, '')
  end

end
