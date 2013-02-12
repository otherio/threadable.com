class ProjectsController < ApplicationController

  before_filter :authenticate_user!

  # GET /projects
  # GET /projects.json
  def index
    @projects = current_user.projects.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /make-a-tank
  # GET /make-a-tank.json
  def show
    @project = current_user.projects.find_by_slug!(params[:project_id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = current_user.projects.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /make-a-tank/edit
  def edit
    @project = current_user.projects.find_by_slug!(params[:project_id])
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = current_user.projects.new(params[:project])
    @project_membership = current_user.project_memberships.new
    @project_membership.project = @project

    respond_to do |format|
      if @project.save && @project_membership.save
        format.html { redirect_to @project, notice: 'current_user.projects was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/make-a-tank
  # PUT /projects/make-a-tank.json
  def update
    @project = current_user.projects.find_by_slug!(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, notice: 'current_user.projects was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/make-a-tank
  # DELETE /projects/make-a-tank.json
  def destroy
    @project = current_user.projects.find_by_slug!(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

end
