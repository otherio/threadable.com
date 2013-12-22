class Organization::HeldMessagesController < ApplicationController

  before_filter :require_user_be_signed_in!

  def index
    @held_messages = project.held_messages.all
  end

  def accept
    held_message.accept!
    flash[:notice] = 'the message was accepted'
    redirect_to project_held_messages_path(project)
  end

  def reject
    held_message.reject!
    flash[:notice] = 'the message was rejected'
    redirect_to project_held_messages_path(project)
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end

  def held_message
    @held_message ||= project.held_messages.find_by_id!(params[:id])
  end

end
