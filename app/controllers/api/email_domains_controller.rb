class Api::EmailDomainsController < ApiController

  def index
    render json: serialize(:email_domains, organization.email_domains.all)
  end

  def create
    domain_params = params.require(:email_domain).permit(:domain)

    domain = organization.email_domains.add!(domain_params[:domain])
    render json: serialize(:email_domains, domain), status: 201

  rescue Threadable::RecordInvalid
    render json: {error: "unable to create domain"}, status: :unprocessable_entity
  end

  def update
    domain_params = params.require(:email_domain).permit(:domain, :outgoing)
    domain = organization.email_domains.find_by_id!(params[:id])
    if domain_params[:outgoing]
      domain.outgoing!
    else
      domain.not_outgoing!
    end
    render json: serialize(:email_domains, domain)
  end


  def destroy
    domain = organization.email_domains.find_by_id(params[:id])
    unless domain
      return render json: {error: "domain is not present"}, status: :unprocessable_entity
    end

    organization.email_domains.remove(domain.domain)
    render json: {}, status: 200
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params.require(:organization_id))
  end

end
