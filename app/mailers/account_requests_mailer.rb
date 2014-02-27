class AccountRequestsMailer < Threadable::Mailer

  def account_request_confirmation(account_request)
    @account_request_confirmation_token = AccountRequestConfirmationToken.encrypt(account_request.id)
    mail(
      to:      account_request.email_address,
      from:    "Threadable account requests <#{threadable.support_email_address('account-requests')}>",
      subject: "Threadable account request",
    )
  end

end
