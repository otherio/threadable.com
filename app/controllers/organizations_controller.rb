class OrganizationsController < ApplicationController

  before_filter :require_user_be_signed_in!

  # GET /make-a-tank
  # GET /make-a-tank.json
  def show
    respond_to do |format|
      format.html { redirect_to organization_conversations_url(organization) }
      format.json { render json: organization }
    end
  end

  # GET /organizations/new
  # GET /organizations/new.json
  def new
    @organization = current_user.organizations.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organization }
    end
  end

  # GET /organizations/edit
  def edit
    @organization = current_user.organizations.find_by_slug! params[:id]
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = current_user.organizations.create(organization_params)

    respond_to do |format|
      if @organization.persisted?
        format.html { redirect_to organization_url(@organization), notice: "#{@organization.name} was successfully created." }
        format.json { render json: @organization, status: :created, location: @organization }
      else
        format.html { render action: "new" }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /organizations/make-a-tank
  # PUT /organizations/make-a-tank.json
  def update
    respond_to do |format|
      if organization.update(organization_params)
        format.html { redirect_to root_path, notice: "#{@organization.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # # GET /organizations/make-like-a-tree-and/join
  # # GET /organizations/make-like-a-tree-and/join.json
  # def join
  #   flash[:notice] = "Welcome aboard! You're now a memeber of the #{organization.name} organization."
  # end

  # PUT /organizations/make-like-a-tree-and/leave
  # PUT /organizations/make-like-a-tree-and/leave.json
  def leave
    respond_to do |format|
      if organization.leave!
        format.html { redirect_to root_path, notice: "You have successfully left #{@organization.name}." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # # DELETE /organizations/make-a-tank
  # # DELETE /organizations/make-a-tank.json
  # def destroy
  #   organization.destroy

  #   respond_to do |format|
  #     format.html { redirect_to organizations_url }
  #     format.json { head :no_content }
  #   end
  # end

  private

  def organization_params
    params.require(:organization).permit(:name, :short_name, :description)
  end

  def organization
    @organization ||= current_user.organizations.find_by_slug! params[:id]
  end

end
