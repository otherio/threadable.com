require 'spec_helper'

describe "Api controllers" do

  when_signed_in_as 'bethany@ucsd.example.com' do

    context "when the request does not accept json" do
      it "renders not acceptable" do
        xhr :get, '/api/users/current'
        expect(response.status).to eq 406
        xhr :get, '/api/users/current.json'
        expect(response.status).to eq 200
      end
    end

  end

end
