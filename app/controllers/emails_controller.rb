class EmailsController < ActionController::Base

  # POST /emails
  def create

    Rails.logger.debug params.inspect

    if EmailProcessor.process_request(request)
      render nothing: true, status: :ok
    else
      render nothing: true, status: :bad_request
    end
  end

end
