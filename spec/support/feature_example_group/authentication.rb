module RSpec::Support::FeatureExampleGroup

  def sign_in! user=covered.current_user
    user.present? or raise ArgumentError, "sign_in! requires a user"
    sign_out!
    visit sign_in_path if current_path != sign_in_path
    within_element 'the sign in form' do
      fill_in 'Email', :with => user.email_address.to_s
      fill_in 'Password', :with => 'password'
      click_on 'Sign in'
    end
    # not sure why we see this error sometimes but retrying seems to fix it - Jared
    begin
      expect(page).to have_content('My Conversations')
    rescue Capybara::Webkit::InvalidResponseError
      raise if @capybara_webkit_invalid_response_error_seen
      @capybara_webkit_invalid_response_error_seen = true
      retry
    end
    covered.current_user_id = user.id
    covered.current_user
  end

  def sign_out!
    visit sign_out_path
    page.should have_content('No password yet? Forgot Password?')
    covered.current_user_id = nil
  end

  def sign_in_as email_address
    sign_in! find_user_by_email_address(email_address)
  end

  def i_am email_address
    covered.current_user_id = find_user_by_email_address(email_address).id
  end

  def expect_to_be_signed_in!
    expect(page).to have_selector selector_for('the current user dropdown')
  end

  def expect_to_be_signed_out!
    expect(page).to_not have_selector selector_for('the current user dropdown')
  end

  def expect_to_be_signed_in_as! user_name
    expect( find('.current-user-controls .name') ).to have_text user_name
  end

  module ClassMethods

    def i_am email_address, &block
      context "I am #{email_address}" do
        before{ i_am email_address }
        class_eval(&block)
      end
    end

    def i_am_a_new_user &block
      context "I am a new user" do
        before{ sign_out! }
        class_eval(&block)
      end
    end

    def i_am_not_signed_in &block
      context "I am not signed in" do
        before { sign_out! }
        class_eval(&block)
      end
    end

    def i_am_signed_in_as email_address, &block
      context "signed in as #{email_address}" do
        before{ sign_in_as email_address }
        class_eval(&block)
      end
    end

  end

end
