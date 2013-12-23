require 'spec_helper'

describe "task_metadata" do

  let(:user   ) { double(:user) }
  # let(:members) { double(:members) }
  let(:organization) { double(:organization) } #, members: members) }

  let(:doers){ double :doers, all: all_doers }
  let(:all_doers){
    [
      double(:doer1, id: 41, name: 'steve', avatar_url: '//foo.jif'),
      double(:doer1, id: 42, name: 'laura', avatar_url: '//foo.ping')
    ]
  }

  let :task do
    double(:task,
      subject: "eat a live goat",
      organization: organization,
      done?: true,
      doers: doers,
      muted?: false,
    )
  end

  def locals
    {
      task: task,
      user: user
    }
  end

  it "renders each doer's avatar" do
    avatars = html.css('.avatar')
    expect( avatars.map(&:text)                        ).to eq all_doers.map(&:name)
    expect( avatars.map{|a| a.css('img').first[:src] } ).to eq all_doers.map(&:avatar_url)
  end

end
