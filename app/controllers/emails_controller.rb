class EmailsController < ApplicationController

  before_filter :authenticate

  # POST /emails
  def create
    mailgun_params = request.params.dup.slice!("controller", "action")
    covered.incoming_emails.create!(mailgun_params)
    render nothing: true, status: 200

  rescue Covered::RecordInvalid
    render nothing: true, status: 500

  rescue Covered::RejectedIncomingEmail => error
    reported_params = mailgun_params.slice(*%w{
      Sender X-Envelope-From From recipient To Cc Subject Date
      In-Reply-To References Message-Id Content-Type
    })
    covered.track("Exception", {
      'Class'   => error.class.name,
      'message' => error.message,
    }.merge(reported_params))
    render nothing: true, status: 406
  end

  private

  def authenticate
    signature = MailgunSignature.encode(params['timestamp'], params['token'])
    signature.eql?(params['signature']) or render nothing: true, status: :bad_request
  end

end
