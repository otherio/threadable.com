class Admin::Organization::MembersController < ApplicationController

  layout 'old'

  before_action :require_user_be_admin!

  # POST /admin/organizations/:organization_slug/members
  def add
    if params.key?(:members)
      add_multiple_members!
    else
      add_single_member!
    end
  end

  def edit
    @member = organization.members.find_by_user_slug!(params[:user_id])
  end

  # PATCH /admin/organizations/:organization_slug/members/:user_id
  def update
    member_params = params.require(:user).permit(:name, :email_address, :slug, :role, :gets_email, :confirmed).symbolize_keys
    member = organization.members.find_by_user_slug! params[:user_id]
    if member.update(member_params)
      flash[:notice] = "update of #{member.formatted_email_address} membership to #{organization.name} was successful."
    else
      flash[:alert] = "update of #{member.formatted_email_address} membership to #{organization.name} was unsuccessful."
    end
    redirect_to admin_edit_organization_path(organization)
  end

  # DELETE /admin/organizations/:organization_slug/members/:user_id
  def remove
    user_slug = params.require(:user_id)
    if member = organization.members.find_by_user_slug!(user_slug)
      organization.members.remove(user: member)
      flash[:notice] = "#{member.formatted_email_address} was successfully removed from #{organization.name}."
    else
      flash[:alert] = "user #{user_slug} is not a member of #{organization.name}."
    end
    redirect_to admin_edit_organization_path(organization)
  end

  private

  def organization
    @organization ||= threadable.organizations.find_by_slug! params[:organization_id]
  end

  def add_multiple_members!
    require 'csv'
    formatted_email_addresses = CSV.parse(params[:members]).flatten(1).compact

    formatted_email_addresses.each do |formatted_email_address|
      begin
        mail_address = Mail::Address.new(formatted_email_address)
      rescue Mail::AddressListsParser, Mail::Field::ParseError
        raise "failed to parse: #{formatted_email_address.inspect}"
      end
      email_address = mail_address.address
      name = mail_address.display_name || email_address.split('@').first.gsub('.',' ')

      user = find_or_create_user_by_email_address!(name, email_address)
      organization.members.add(
        user:             user,
        send_join_notice: params[:send_join_notice],
        personal_message: params[:personal_message],
      )
    end

    flash[:notice] = "#{formatted_email_addresses.size} new members were successfully added to #{organization.name}."

    redirect_to admin_edit_organization_path(organization)
  end


  def add_single_member!
    user = find_or_create_user!
    if organization.members.include? user
      flash[:alert] = "#{user.formatted_email_address} is already a member of #{organization.name}."
    else
      member = organization.members.add(
        user:             user,
        gets_email:       member_params[:gets_email],
        send_join_notice: member_params[:send_join_notice],
        personal_message: member_params[:personal_message],
      )
      flash[:notice] = "#{member.formatted_email_address} was successfully added to #{organization.name}."
    end
    redirect_to admin_edit_organization_path(organization)
  rescue Threadable::RecordNotFound
    redirect_to admin_edit_organization_path(organization), alert: "unable to find user #{member_params[:id]}"
  end

  def member_params
    @member_params or begin
      @member_params = params.require(:user).permit(:id, :name, :email_address, :gets_email, :send_join_notice, :confirmed).symbolize_keys
      @member_params[:gets_email]       = @member_params[:gets_email] == 'true'
      @member_params[:confirmed]        = @member_params[:confirmed] == 'true'
      @member_params[:send_join_notice] = @member_params[:send_join_notice] == 'true'
      @member_params[:personal_message] = params[:personal_message]
    end
    @member_params
  end

  def find_or_create_user!
    if member_params.key?(:id)
      threadable.users.find_by_id!(member_params[:id].to_i)
    else
      find_or_create_user_by_email_address! member_params[:name], member_params[:email_address]
    end
  end


  def find_or_create_user_by_email_address! name, email_address
    threadable.users.find_by_email_address(email_address) or
    threadable.users.create!(name: name, email_address: email_address)
  end

end
