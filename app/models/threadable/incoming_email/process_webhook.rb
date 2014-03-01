require_dependency 'threadable/incoming_email'

class Threadable::IncomingEmail::ProcessWebhook < MethodObject

  InvalidResponse = Class.new(StandardError)

  MUTABLE_PARAMS = %w{
    body-html
    body-plain
    stripped-html
    stripped-text
  }.freeze

  def call incoming_email, url
    threadable = incoming_email.threadable
    params     = incoming_email.params

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
      threadable.track('web hook called', url: url, successful: false)
      return params
    end

    threadable.track('web hook called', url: url, successful: true)
    return params
  end

end
