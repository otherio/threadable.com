module CapybaraEnvironment::NewConversationMessage

  def fill_in_new_conversation_message_subject value
    within '.new_conversation_message' do
      fill_in 'subject', with: value
    end
  end

  def focus_new_conversation_message_body!
    within '.new_conversation_message' do
      find_field('Add your voice...').click
    end
  end

  def fill_in_new_conversation_message_body value
    if page.has_selector? '.new_conversation_message .body_field textarea'
      focus_new_conversation_message_body!
    end
    fill_in_wysiwyg value
  end

  def fill_in_new_conversation_message options
    fill_in_new_conversation_message_subject options[:subject] if options.key? :subject
    fill_in_new_conversation_message_body options[:body] if options.key? :body
    within('.new_conversation_message'){ click_button 'Send' } if options[:send]
  end

end
