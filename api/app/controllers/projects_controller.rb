class ProjectsController < ApplicationController

  before_filter :find, :only => [:show, :update, :destroy]
  before_filter :authenticate_user!

  # def authenticate
  #   resource = warden.authenticate!(:scope => :user, :recall => "#{controller_path}#failure")
  #   scope = Devise::Mapping.find_scope!(:user)
  #   sign_in(scope, resource) unless warden.user(scope) == resource
  # end

  # GET /projects
  # GET /projects.json
  def index
    @projects = current_user.projects

    respond_to do |format|
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    respond_to do |format|
      format.json { render json: @project }
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    Project.transaction do
      @project = Project.new(params[:project])
      @project.members << current_user
    end

    respond_to do |format|
      if @project.save
        format.json { render json: @project, status: :created, location: @project }
      else
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.json { render json: @project, status: :ok, location: @project }
      else
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    if @project.project_memberships.where(:user_id => current_user.id).first.moderator
      @project.destroy

      respond_to do |format|
        format.json { render json: @project, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render nothing: true, status: :forbidden }
      end
    end
  end

  private

  def find
    @project = current_user.projects.where('projects.id = ? or projects.slug = ?', params[:id], params[:id]).first

    if ! @project.present?
      respond_to do |format|
        format.json { render nothing: true, status: :not_found }
      end
    end
  end

end
