class AccountRequestsController < ApplicationController

  skip_before_action :require_user_be_signed_in!

  def create
    account_request_params = params.require(:account_request).permit(
      :organization_name, :email_address
    )
    account_request = AccountRequest.create!(account_request_params)
    threadable.emails.send_email_async :account_request_confirmation, account_request.id
    threadable.track('Account requested',{
      account_request_id: account_request.id,
      organization_name:  account_request.organization_name,
      email_address:      account_request.email_address,
    })
  end

  def confirm
    account_request_id = AccountRequestConfirmationToken.decrypt(params.require(:token))
    account_request = AccountRequest.find(account_request_id)
    account_request.confirm!
    threadable.track('Account request confirmed',{
      account_request_id: account_request.id,
      organization_name:  account_request.organization_name,
      email_address:      account_request.email_address,
    })
  end

end
