class PostmarkSpamcheck
  include HTTParty

  headers 'Accept' => 'application/json'
  headers 'Content-type' => 'application/json'
  format :json

  def initialize mail_message
    @mail_message = mail_message[0,16384]
  end

  attr_reader :mail_message

  def score
    payload = {email: mail_message, options: 'short'}
    response = self.class.post("http://spamcheck.postmarkapp.com/filter", body: payload.to_json)

    response.code < 300 && response.respond_to?(:[]) or raise Threadable::ExternalServiceError, "Spamcheck failed with error #{response.code}: #{response.body}"
    response['success'] == true or raise Threadable::ExternalServiceError, "Spamcheck application error: #{response['message']}"
    response['score'].to_f
  end
end
