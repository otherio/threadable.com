require 'spec_helper'

describe "Authentication" do

  describe "sign in/out" do

    let!(:user){ Covered::User.where(name: "Alice Neilson").first! }

    it "I can sign in and sign out" do

      post sign_in_path, {
        "authentication" => {
          "email"       => user.email,
          "password"    => "password",
        },
      }
      expect(response).to be_success
      expect( controller.current_user ).to eq user
      expect( controller.covered      ).to eq Covered.new(current_user_id: user.id, host: request.host, port: request.port, protocol: 'http')

      get sign_out_path
      expect(response).to redirect_to root_url
      expect( controller.current_user ).to be_nil
      expect( controller.covered      ).to eq Covered.new(current_user_id: nil, host: request.host, port: request.port, protocol: 'http')


      post sign_in_path, {
        "authentication" => {
          "email"       => user.email,
          "password"    => "WRONG PASSWORD",
        },
      }
      expect(response).to_not be_success
      expect( controller.current_user ).to be_nil
      expect( controller.covered      ).to eq Covered.new(current_user_id: nil, host: request.host, port: request.port, protocol: 'http')


      # visit sign_in_path
      # fill_in 'Email', with: user.email
      # fill_in 'Password', with: 'password'
      # click_button 'Sign in'
      # page.should have_content user.name
      # page.current_path.should == root_path
      # within selector_for('the navbar') do
      #   click_on user.name
      #   click_on 'Sign out'
      # end
      # page.should_not have_content user.name
      # page.current_path.should == root_path
    end

  end

end
