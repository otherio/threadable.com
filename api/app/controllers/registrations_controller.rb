class RegistrationsController < Devise::RegistrationsController
  def create
    respond_to do |format|
      format.html {
        super
      }
      format.json {
        build_resource
        if resource.save
           render :status => 201, :json => resource
        else
          render :json => resource.errors, :status => :unprocessable_entity
        end
      }
    end
  end

  def after_sign_up_path_for(resource)
    # how in the world do we test this?
    user_path(resource)
  end
end
