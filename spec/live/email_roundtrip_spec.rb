require 'spec_helper'

feature 'email roundtrip' do

  scenario 'sending an email via the web' do
    as 'threadable-auto-deploy@mailinator.com', 'bonkatron' do
      subject_line = "Test web compose #{Time.now.to_i}"

      visit '/auto-deploy-tests/conversations'
      click_on 'Compose'
      fill_in 'message_subject', with: subject_line
      page.execute_script(%(
        $('iframe.wysihtml5-sandbox')
          .contents()
          .find('body')
          .html('Lorem testing batman asdf')
      ))
      click_on 'Send'
      page.should have_content subject_line

      sleep 10  # we are bad people.
      visit 'http://mailinator.com/inbox.jsp?to=threadable-auto-deploy'
      Capybara.using_wait_time(20) do
        page.should have_content subject_line
      end
    end
  end

  scenario 'receiving an email and sending it to subscribers' do
    subject_line = "Test email compose #{Time.now.to_i}"

    send_simple_message 'threadable-auto-deploy@mailinator.com', subject_line, "booyakasha in the hizzouse."

    sleep 10  # we'll burn in hell for this
    visit 'http://mailinator.com/inbox.jsp?to=threadable-auto-deploy'
    Capybara.using_wait_time(20) do
      page.should have_content subject_line
    end
  end
end




# more address!
# threadable-auto-deploy@mailismagic.com
# m8r-vlfenq@mailinator.com
# threadable-auto-deploy@mailinator.com
# threadable-auto-deploy@spamgoes.in
# threadable-auto-deploy@mailtothis.com
