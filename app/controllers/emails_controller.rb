class EmailsController < ActionController::Base

  before_filter :authenticate

  # POST /emails
  def create
    email_params = request.params.dup.slice!("controller", "action")
    incoming_email = IncomingEmail.create!(params: email_params)
    ProcessEmailWorker.enqueue(incoming_email_id: incoming_email.id)
    render nothing: true, status: :ok
  end

  private

  def authenticate
    signature = MailgunSignature.encode(params['timestamp'], params['token'])
    signature.eql?(params['signature']) or render nothing: true, status: :bad_request
  end

end
