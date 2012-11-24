class MembershipsController < ApplicationController

  before_filter :find, :only => [:show, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = ProjectMembership.scoped

    @users = @users.where(:email => params[:email])       if params[:email]
    @users = @users.where(:password => params[:password]) if params[:password]

    respond_to do |format|
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.json { render json: @user }
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = ProjectMembership.new(params[:user])

    respond_to do |format|
      if @user.save
        format.json { render json: @user, status: :created, location: @user }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.json { render json: @user, status: :ok, location: @user }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def find
    @user = ProjectMembership.find_by_id(params[:id])
  end

end
