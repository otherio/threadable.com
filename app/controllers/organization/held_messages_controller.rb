class Organization::HeldMessagesController < ApplicationController

  before_filter :require_user_be_signed_in!

  layout 'inside'

  def index
    @held_messages = organization.held_messages.all
  end

  def accept
    held_message.accept!
    flash[:notice] = 'the message was accepted'
    redirect_to organization_held_messages_path(organization)
  end

  def reject
    held_message.reject!
    flash[:notice] = 'the message was rejected'
    redirect_to organization_held_messages_path(organization)
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id])
  end

  def held_message
    @held_message ||= organization.held_messages.find_by_id!(params[:id])
  end

end
