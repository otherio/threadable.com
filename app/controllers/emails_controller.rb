class EmailsController < ActionController::Base

  before_filter :authenticate

  # POST /emails
  def create
    email_data = request.params.dup.slice!("controller", "action")
    EmailProcessor.encode_attachements(email_data)
    ProcessEmailWorker.enqueue(email_data)
    render nothing: true, status: :ok
  end

  private

  def authenticate
    signature = MailgunSignature.encode(params['timestamp'], params['token'])
    signature.eql?(params['signature']) or render nothing: true, status: :bad_request
  end

end
