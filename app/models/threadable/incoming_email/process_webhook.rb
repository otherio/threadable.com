require_dependency 'threadable/incoming_email'

class Threadable::IncomingEmail::ProcessWebhook < MethodObject

  InvalidResponse = Class.new(StandardError)

  MUTABLE_PARAMS = %w{
    body-html
    body-plain
    stripped-html
    stripped-text
  }.freeze

  def call threadable, url, params
    begin
      response = HTTParty.post(url, body: params)
      response.code < 300 && response.respond_to?(:[]) or raise InvalidResponse,
        "invalid response from #{url}. code: #{response.code}, body: #{response.inspect}"

      MUTABLE_PARAMS.each do |param|
        params["BEFORE_WEBHOOK_#{param}"] ||= params[param]
        params[param] = response[param]
      end
    rescue Exception => exception
      threadable.report_exception!(exception,{
        incoming_email_webhook_failed: true
      })
    end
    return params
  end

end
