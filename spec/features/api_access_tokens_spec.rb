require 'spec_helper'

feature "API access tokens" do

  before do
    sign_in_as 'yan@ucsd.example.com'
    visit profile_url
  end

  scenario %(generating an api access token) do
    expect(page).to have_text %(Generate an access token)
    click_on 'Generate'
    expect(current_url).to eq profile_url

    access_token = find_field('api_access_token').value
    response = get "/api/users/current.json?access_token=#{access_token}"
    expect(response.code).to eq 200
    expect(response["user"]["name"]).to eq 'Yan Hzu'

    click_on 'Regenerate'
    accept_prompt!
    expect(page).to have_text %(API Access Token has been generated)
    response = get "/api/users/current.json?access_token=#{access_token}"
    expect(response.code).to eq 401
    expect(response["error"]).to eq "Unauthorized"

    access_token = find_field('api_access_token').value
    response = get "/api/users/current.json?access_token=#{access_token}"
    expect(response.code).to eq 200
    expect(response["user"]["name"]).to eq 'Yan Hzu'
  end

  def get path
    HTTParty.get("http://#{Capybara.server_host}:#{Capybara.server_port}#{path}")
  end
end
