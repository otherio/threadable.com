class Project::MembersController < ApplicationController

  before_filter :authenticate_user!

  respond_to :json


  # GET /projects/make-a-tank/members
  # GET /projects/make-a-tank/members.json
  def index
    @members = project.members

    respond_to do |format|
      format.html
      format.json { render json: @members }
    end
  end

  # POST /projects/make-a-tank/members.json
  def create
    member = User.where(id: params[:member][:id]).first
    return head :not_found if member.blank?
    if project.members << member
      respond_with member, status: :created
    else
      respond_with member, status: :unprocessable_entity
    end
  end

  # DELETE /projects/make-a-tank/members.json
  def destroy
    project.members.where(slug: params[:id]).first!.destroy
    head :no_content
  end

  private

  def project
    @project ||= current_user.projects.where(slug: params[:project_id]).first!
  end



  # this will become the overall user search for invites maybe later.
  # describe "GET user_search" do
  #   let!(:project) {create(:project) }
  #   let!(:user_alice) { create(:user, name: 'Alice', email: 'alice@example.com') }
  #   let!(:user_bob) { create(:user, name: 'Bob', email: 'bob@example.com') }

  #   before do
  #     project.members << [user_alice, user_bob]
  #   end

  #   context "searching by email address" do
  #     subject { xhr :get, :user_search, {:project_id => project.to_param, :q => 'exampl'} }

  #     it "fetches users by email address" do
  #       subject
  #       response.should be_success
  #       result = response.body.JSON_decode
  #       result.length.should == 2
  #     end

  #     it "correctly formats its results" do
  #       subject
  #       result = response.body.JSON_decode
  #       result.should =~ [
  #         { 'name' => 'Alice', 'email' => 'alice@example.com', 'id' => alice_user.id },
  #         { 'name' => 'Bob', 'email' => 'bob@example.com', 'id' => bob_user.id },
  #       ]
  #     end
  #   end

  #   context "searching by name" do
  #     subject { xhr :get, :user_search, {:project_id => project.to_param, :q => 'ali'} }

  #     it "fetches users by name substring" do
  #       subject
  #       response.should be_success
  #       result = response.body.JSON_decode
  #       result.length.should == 1
  #     end
  #   end

  #   context "with many users" do
  #     before do
  #       (1..20).each do |seq|
  #         create(:user, email: "#{seq}@example.com")
  #       end
  #     end

  #     it "fetches a maximum of ten results" do
  #       xhr :get, :user_search, {:project_id => project.to_param, :q => 'example.com'}
  #       result = response.body.JSON_decode
  #       result.length.should == 10
  #     end
  #   end

  #   context "when the user doesn't have access to this project" do
  #     it "returns a 404 or something" do
  #       pending
  #     end
  #   end

  #   context "when fetching HTML instead of json" do
  #     it "returns not implemented, or something like that" do
  #     end
  #   end
  # end

end
