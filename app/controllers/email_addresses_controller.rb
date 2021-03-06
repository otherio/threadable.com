class EmailAddressesController < ApplicationController

  before_filter :require_user_be_signed_in!, except: [:confirm]

  def create
    email_address = current_user.email_addresses.add(email_address_params[:address], !!email_address_params[:primary])
    if email_address.persisted?
      flash[:notice] = "We've sent a confirmation email to #{email_address}. Please check your email."
      threadable.emails.send_email_async(:email_address_confirmation, email_address.id)
    else
      flash[:error] = email_address.errors.full_messages.to_sentence
    end
    redirect_to profile_path(expand_section: 'email')
  end

  def update
    if email_address_params[:primary]
      email_address.primary!
      flash[:notice] = "#{email_address} is now your primary email address."
    end
    redirect_to profile_path(expand_section: 'email')
  end

  def resend_confirmation_email
    flash[:notice] = "We've resent a confirmation email to #{email_address}. Please check your email."
    threadable.emails.send_email_async(:email_address_confirmation, email_address.id)
    redirect_to profile_path(expand_section: 'email')
  end

  def confirm
    email_address_id = EmailAddressConfirmationToken.decrypt(params[:token])
    email_address = threadable.email_addresses.find_by_id!(email_address_id)
    email_address.confirm!
    flash[:notice] = "#{email_address} has been confirmed"

    if signed_in? && email_address.user.id == current_user_id
      redirect_to profile_path(expand_section: 'email')
    else
      redirect_to sign_in_path(r: profile_path(expand_section: 'email'))
    end
  end

  private

  def email_address
    @email_address ||= current_user.email_addresses.find_by_address!(email_address_params[:address])
  end

  def email_address_params
    @email_address_params ||= params.require(:email_address).permit(:address, :primary)
  end

end
