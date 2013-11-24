class EmailsController < ApplicationController

  before_filter :authenticate

  # POST /emails
  def create
    email_params = request.params.dup.slice!("controller", "action")
    incoming_email = IncomingEmail.create!(params: email_params)
    ProcessIncomingEmailWorker.perform_async(covered.env, incoming_email.id)
    render nothing: true, status: :ok
  end

  private

  def authenticate
    signature = MailgunSignature.encode(params['timestamp'], params['token'])
    signature.eql?(params['signature']) or render nothing: true, status: :bad_request
  end

end
