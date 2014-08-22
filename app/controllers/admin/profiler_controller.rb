class Admin::ProfilerController < ApplicationController

  before_action :require_user_be_admin!

  def show
    worker = SendEmailWorker.new()
    worker.perform(threadable.env, :conversation_message, 151, 7588, 16)
  end

end
