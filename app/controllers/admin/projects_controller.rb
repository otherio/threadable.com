class Admin::ProjectsController < ApplicationController

  before_filter :require_user_be_admin!

  # GET /admin/projects
  def index
    @projects = covered.projects.all
  end

  # GET /admin/projects/new
  def new
    @project = covered.projects.new
  end

  # POST /admin/projects
  def create
    @project = covered.projects.create(project_params)

    if project.persisted?
      redirect_to admin_edit_project_path(project), notice: 'Project was successfully created.'
    else
      render action: 'new'
    end
  end

  # GET /admin/projects/1/edit
  def edit
    project
    @members = project.members.all
    @all_users = covered.users.all
  end

  # PATCH /admin/projects/1
  def update
    if project.update(project_params)
      redirect_to admin_edit_project_path(project), notice: 'Project was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/projects/1
  def destroy
    project.destroy!
    redirect_to admin_projects_url, notice: 'Project was successfully destroyed.'
  end

  private

  def project
    @project ||= covered.projects.find_by_slug! params[:id]
  end

  def project_params
    @project_params or begin
      @project_params = params.require(:project).permit(
        :name,
        :subject_tag,
        :slug,
        :email_address_username,
        :add_current_user_as_a_member,
      ).symbolize_keys
      if @project_params.key? :add_current_user_as_a_member
        @project_params[:add_current_user_as_a_member] = @project_params[:add_current_user_as_a_member] == "1"
      end
    end
    @project_params
  end

  # this is here so the page navigation project section is not rendered
  def current_project
  end
  helper_method :current_project

end
