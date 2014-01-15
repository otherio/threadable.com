require 'spec_helper'

describe "Authentication" do

  describe "sign in/out" do

    let(:alice){ find_user_by_email_address 'alice@ucsd.example.com' }

    it "I can sign in and sign out" do

      post sign_in_path, {
        "email_address" => 'alice@ucsd.example.com',
        "password"      => "password",
      }
      expect(response).to be_success
      expect( controller.current_user.id ).to eq alice.id
      expect( controller.covered         ).to eq Covered.new(protocol: 'http', host: request.host, port: request.port, current_user_id: alice.id)

      post sign_out_path
      expect(response).to be_success

      # how do we check signed-outness here?
      expect( controller.current_user    ).to be_nil
      expect( controller.covered         ).to eq Covered.new(protocol: 'http', host: request.host, port: request.port)

      post sign_in_path, {
        "email_address" => 'alice@ucsd.example.com',
        "password"      => "WRONG PASSWORD",
      }
      expect(response).to_not be_success
      expect( controller.current_user ).to be_nil
      expect( controller.covered      ).to eq Covered.new(protocol: 'http', host: request.host, port: request.port)
    end

  end

end
