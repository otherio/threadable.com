class EmailsController < ApplicationController

  before_filter :authenticate

  # POST /emails
  def create
    mailgun_params = request.params.dup.slice!("controller", "action")
    covered.incoming_emails.create!(mailgun_params)
    render nothing: true, status: :ok
  rescue Covered::RecordInvalid => error
    Honeybadger.notify(error)
    render nothing: true, status: :bad_request
  end

  private

  def authenticate
    signature = MailgunSignature.encode(params['timestamp'], params['token'])
    signature.eql?(params['signature']) or render nothing: true, status: :bad_request
  end

end
