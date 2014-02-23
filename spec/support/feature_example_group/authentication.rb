module RSpec::Support::FeatureExampleGroup

  def sign_in! user=threadable.current_user
    user.present? or raise ArgumentError, "sign_in! requires a user"
    sign_out!
    visit sign_in_path if current_path != sign_in_path
    Timeout::timeout(10) do
      within_element 'the sign in form' do
        fill_in 'Email Address', :with => user.email_address.to_s
        fill_in 'Password', :with => 'password'
        click_on 'Sign in'
      end
      expect(page).to have_text 'My Conversations'
      threadable.current_user_id = user.id
      threadable.current_user
    end
  rescue Timeout::Error
    raise if @timed_out_while_signing_in
    @timed_out_while_signing_in = true
    retry
  end

  def sign_out!
    visit sign_out_path
    expect(page).to be_at_url sign_in_url
    threadable.current_user_id = nil
  end

  def sign_in_as email_address
    sign_in! find_user_by_email_address(email_address)
  end

  def i_am email_address
    threadable.current_user_id = find_user_by_email_address(email_address).id
  end

  def expect_to_be_signed_in!
    expect(page).to have_selector selector_for('the current user dropdown')
  end

  def expect_to_be_signed_out!
    expect(page).to_not have_selector selector_for('the current user dropdown')
  end

  def expect_to_be_signed_in_as! user_name
    expect( find('.sidebar .user-controls .name') ).to have_text user_name
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
