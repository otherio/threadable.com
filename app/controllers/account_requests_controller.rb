class AccountRequestsController < ApplicationController

  skip_before_action :require_user_be_signed_in!

  def create
    account_request_params = params.require(:account_request).permit(
      :organization_name, :email_address
    )
    account_request = AccountRequest.create(account_request_params)
    if account_request.persisted?
      threadable.emails.send_email_async :account_request_confirmation, account_request.id
      threadable.track('Account requested',{
        account_request_id: account_request.id,
        organization_name:  account_request.organization_name,
        email_address:      account_request.email_address,
      })
      render json: {}, status: :created
    else
      render json: {errors: account_request.errors.as_json}, status: :not_acceptable
    end
  end

  def confirm
    sign_out!
    account_request_id = AccountRequestConfirmationToken.decrypt(params.require(:token))
    account_request = AccountRequest.find(account_request_id)
    account_request.confirm!
    threadable.track('Account request confirmed',{
      account_request_id: account_request.id,
      organization_name:  account_request.organization_name,
      email_address:      account_request.email_address,
    })

    user = threadable.users.find_by_email_address(account_request.email_address)
    user ||= threadable.users.create!(email_address: account_request.email_address)
    if user
      sign_in! user
      redirect_to new_organization_path(organization_name: account_request.organization_name)
    end
  end

end
