require 'spec_helper'

describe "mute_conversation_link" do

  let(:organization){ double(:organization, to_param: 'lamma-pajammas') }
  let(:conversation){ double(:conversation, to_param: 'what-color', organization: organization, muted?: false) }

  def locals
    {conversation: conversation, content: 'lick your face'}
  end

  it "renders a link to mute the given conversation" do
    expect(html.text).to include 'lick your face'
  end

end
