require 'spec_helper'

describe "Authentication" do

  describe "sign in/out" do

    let(:alice){ find_user_by_email_address 'alice@ucsd.example.com' }

    it "I can sign in and sign out" do
      post sign_in_path, {
        "authentication" => {
          "email_address" => 'alice@ucsd.example.com',
          "password"      => "WRONG PASSWORD",
        }
      }
      expect(response).to be_success
      expect(response.body).to include 'Bad email address or password'
      expect(controller.current_user).to be_nil

      post sign_in_path, {
        "authentication" => {
          "email_address" => 'alice@ucsd.example.com',
          "password"      => "password",
        }
      }
      expect(response).to redirect_to root_url
      expect(controller.current_user).to be_the_same_user_as alice

      get sign_out_path
      expect(response).to redirect_to root_url
      expect(controller.current_user).to be_nil

      post recover_password_path, {
        "password_recovery" => {
          "email_address" => 'alice@ucsd.example.com',
        }
      }
      expect(response).to be_success
      expect(response.body).to include "We've emailed you a password reset link"
    end

  end

end
