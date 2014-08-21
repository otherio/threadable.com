require 'spec_helper'

describe 'model relationships', :type => :request do

  let!(:organization){ Organization.where(name: "UCSD Electric Racing").first! }

  def member(email)
    organization.members.with_email_address(email).first!
  end

  def conversation(subject)
    organization.conversations.where(subject: subject).first!
  end

  def task(subject)
    organization.tasks.where(subject: subject).first!
  end

  it "should work" do
    expect(organization).to be_a Organization

    expect(organization.name).to eq 'UCSD Electric Racing'
    expect(organization.description).to eq 'Senior engineering electric race team!'

    expect(organization.conversations).to match_array Conversation.where(organization_id: organization.id)

    expect(organization.tasks).to match_array Task.where(organization_id: organization.id)

    expect(organization.tasks).to match_array organization.conversations.select(&:task?)

    expect(organization.members).to match_array OrganizationMembership.where(organization_id: organization.id).includes(:user).map(&:user)

    expect(organization.tasks.not_done).to match_array Task.where(organization_id: organization.id).where('done_at IS NULL')
    expect(organization.tasks.done).to match_array Task.where(organization_id: organization.id).where('done_at IS NOT NULL')

    organization.conversations.each do |conversation|
      expect(conversation.messages_count).to eq conversation.messages.count
    end
  end

end
