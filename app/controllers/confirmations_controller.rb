class ConfirmationsController < Devise::ConfirmationsController

  def show
    self.resource = resource_class.find_by_confirmation_token(params[:confirmation_token]) if params[:confirmation_token].present?
    super if resource.nil? or resource.confirmed?
  end

  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    if successfully_sent?(resource)
      respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
    else
      self.resource = User.new(email: params[:user][:email]) if self.resource.new_record?
      flash.now[:error] = "A user with that email could not be found."
      render :new
    end
  end

  def confirm
    self.resource = resource_class.find_by_confirmation_token(params[resource_name][:confirmation_token]) if params[resource_name][:confirmation_token].present?
    if self.resource.nil?
      return redirect_to root_path, status: :not_found
    end
    resource.password_required = true
    resource.password = params[resource_name][:password]
    resource.password_confirmation = params[resource_name][:password_confirmation]

    if resource.valid?
      self.resource = resource_class.confirm_by_token(params[resource_name][:confirmation_token])
      set_flash_message :notice, :confirmed
      sign_in_and_redirect(resource_name, resource)
    else
      render :action => "show"
    end
  end



end
