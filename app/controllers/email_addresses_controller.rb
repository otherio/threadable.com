class EmailAddressesController < ApplicationController

  before_filter :require_user_be_signed_in!

  def create
    email_address = current_user.email_addresses.add(email_address_params[:address], !!email_address_params[:primary])
    flash[:error] = email_address.errors.full_messages.to_sentence unless email_address.persisted?
    redirect_to request.referrer || profile_path
  end

  def update
    email_address = current_user.email_addresses.find_by_address!(email_address_params[:address])
    if email_address_params[:primary]
      email_address.primary!
      flash[:notice] = "#{email_address} is now your primary email address."
    end
    redirect_to request.referrer || profile_path
  end

  private

  def email_address_params
    @email_address_params ||= params.require(:email_address).permit(:address, :primary)
  end

end
