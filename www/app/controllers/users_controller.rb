class UsersController < ApplicationController

  before_filter :find, :only => [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = Multify::User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = Multify::User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit

  end

  # POST /users
  # POST /users.json
  def create
    @user = Multify::User.new(params[:user])

    respond_to do |format|
      if @user.save
        authenticate(@user.email, params[:user][:password])
        format.html { redirect_to root_url, notice: "Hi #{@user.name}, Welcome to Multify" }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(params[:user]).save
        format.html { redirect_to user_url(@user.slug), notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private

  def find
    @user = Multify::User.find(slug: params[:id]).last
    @user.present? or raise 'RecordNotFound'
  end
end
