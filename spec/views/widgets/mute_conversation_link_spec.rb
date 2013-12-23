require 'spec_helper'

describe "mute_conversation_link" do

  let(:organization){ double(:organization, to_param: 'lamma-pajammas') }
  let(:conversation){ double(:conversation, to_param: 'what-color', organization: organization) }

  def locals
    {conversation: conversation}
  end

  it "renders a link to mute the given conversation" do
    link = html.css(:a).first
    expect(link[:href]).to eq mute_organization_conversation_path('lamma-pajammas', 'what-color')
    expect(link['data-method']).to eq 'POST'
    expect(link.text).to include 'mute conversation'
  end

end
