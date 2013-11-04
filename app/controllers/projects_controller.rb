class ProjectsController < ApplicationController

  before_filter :require_user_be_signed_in!

  # GET /projects
  # GET /projects.json
  def index
    @projects = covered.projects.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /make-a-tank
  # GET /make-a-tank.json
  def show
    @project = covered.projects.get slug: params[:id]

    respond_to do |format|
      format.html { redirect_to project_conversations_url(@project) }
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = covered.projects.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/edit
  def edit
    @project = covered.projects.get slug: params[:id]
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = covered.projects.create attributes: project_params

    respond_to do |format|
      if @project.persisted? && @project.members << current_user
        format.html { redirect_to project_url(@project), notice: "#{@project.name} was successfully created." }
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
    @project = current_user.projects.find_by_slug!(params.require(:id))

    respond_to do |format|
      if @project.update_attributes(project_params)
        format.html { redirect_to root_path, notice: "#{@project.name} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /projects/make-like-a-tree-and/join
  # GET /projects/make-like-a-tree-and/join.json
  def join
    flash[:notice] = "Welcome aboard! You're now a memeber of the #{project.name} project."
  end

  # PUT /projects/make-like-a-tree-and/leave
  # PUT /projects/make-like-a-tree-and/leave.json
  def leave
    @project = current_user.projects.find_by_slug!(params.require(:id))

    respond_to do |format|
      if current_user.projects.delete(@project)
        format.html { redirect_to projects_path, notice: "You have successfully abandoned #{@project.name}." }
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
    @project = current_user.projects.find_by_slug!(params.require(:id))
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :short_name, :description)
  end

end
