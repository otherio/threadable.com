class SessionsController < Devise::SessionsController
  
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    return sign_in_and_redirect(resource_name, resource)
  end
  
  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    # if we want redirects later...
    #return render :json => {:success => true, :redirect => stored_location_for(scope) || after_sign_in_path_for(resource), :user => current_user }
    return render :json => {:success => true, :user => current_user, :authentication_token => current_user.authentication_token }

  end

  def failure
    return render :json => {:success => false, :errors => ["Login failed."]}, :status => 401
  end
end
