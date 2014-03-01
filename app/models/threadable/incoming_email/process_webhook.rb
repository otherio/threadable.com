require_dependency 'threadable/incoming_email'

class Threadable::IncomingEmail::ProcessWebhook < MethodObject

  MUTABLE_PARAMS = %w{
    body-html
    body-plain
    stripped-html
    stripped-text
  }.freeze

  def call url, params
    response = HTTParty.post(url, body: params)
    return unless response.code < 300 && response.respond_to?(:[])

    MUTABLE_PARAMS.each do |param|
      # next if response[param] == params[param]
      params["BEFORE_WEBHOOK_#{param}"] ||= params[param]
      params[param] = response[param]
    end
  # rescue Exception => exception
    # incoming_email.threadable.report_exception!(exception)
  ensure
    return params
  end

end
