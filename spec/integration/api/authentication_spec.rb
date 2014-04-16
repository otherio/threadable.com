require 'spec_helper'

describe "api authentication" do

  context 'using a valid access token' do
    before do
      sign_in_as 'alice@ucsd.example.com'
      @alice_token = current_user.regenerate_api_access_token!

      sign_in_as 'mquinn@sfhealth.example.com'
      @mquinn_token = current_user.regenerate_api_access_token!
    end

    it 'fails with no token' do
      expect(get('/api/users/current.json')).to eq 401
    end

    it 'accepts the access token in the url' do
      expect(get("/api/users/current.json?access_token=#{@alice_token}")).to eq 200
      expect(JSON.parse(response.body)["user"]["name"]).to eq "Alice Neilson"

      expect(get("/api/users/current.json?access_token=#{@mquinn_token}")).to eq 200
      expect(JSON.parse(response.body)["user"]["name"]).to eq "Michaela Quinn"
    end

    it 'accepts the access token in a header' do
      expect(get("/api/users/current.json", nil, {'Access-Token' => @mquinn_token.to_s})).to eq 200
      expect(JSON.parse(response.body)["user"]["name"]).to eq "Michaela Quinn"
    end
  end

end
