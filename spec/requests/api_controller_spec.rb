require 'spec_helper'

describe "Api controllers" do

  context "when the request does not accept json", fixtures: false do
    it "renders not acceptable" do
      get '/api/users/current'
      expect(response.status).to eq 406
      get '/api/users/current.json'
      expect(response.status).to eq 200
    end
  end

end
