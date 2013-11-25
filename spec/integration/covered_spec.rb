require 'spec_helper'

describe "covered", fixtures: false do
  it "should work" do
    expect{ Covered.new }.to raise_error ArgumentError, 'required options: :host'

    project = covered.projects.create! name: 'Save The Fishies'
    expect(project).to be_persisted
    expect(project.members.all).to be_empty

    frank = covered.users.create! name: 'Frank Rizzo', email_address: 'frak@rizz.io'

    project.members.add(frank)

    expect(project.members).to include frank
  end
end
