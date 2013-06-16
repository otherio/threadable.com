module TestEnvironment::EmailParams

  def attachments_for_email_params(params)
    1.upto(params['attachment-count'].to_i).map do |n|
      attachment = params["attachment-#{n}"]
      attachment.seek(0) if attachment.respond_to? :seek
      attachment
    end
  end

end
