class ProjectsController < ApplicationController

  before_filter :find, :only => [:show, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.scoped

    @projects = User.find(params[:user_id]).projects if params[:user_id]

    @projects = @projects.where(slug: params[:slug]) if params[:slug]

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
    @project = Project.new(params[:project])

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
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  private

  def find
    @project = Project.find(params[:id])
  end

end
