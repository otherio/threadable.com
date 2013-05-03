# Encoding: UTF-8
class ConversationMailer < ActionMailer::Base

  def conversation_message(message)
    @message = message

    subject_tag = @message[:project_slug][0..6]

    subject = @message[:message_subject].include?("[#{subject_tag}]") ?
      @message[:message_subject] : "[#{subject_tag}] #{@message[:message_subject]}"

    # add a check mark to the subect if the conversation is a task, and if the subject doesn't already include one
    subject = "✔ #{subject}" if @message[:is_a_task] && !subject.include?("✔")

    from = %("#{@message[:sender_name]}" <#{@message[:sender_email]}>)

    unsubscribe_token = UnsubscribeToken.encrypt(@message[:project_id], @message[:recipient_id])
    @unsubscribe_url = project_unsubscribe_url(@message[:project_slug], unsubscribe_token)

    mail(
      :'to'          => %(#{@message[:recipient_name].inspect} <#{@message[:recipient_email]}>),
      :'subject'     => subject,
      :'from'        => from,
      :'Reply-To'    => @message[:reply_to],
      :'Message-ID'  => @message[:message_message_id_header],
      :'In-Reply-To' => @message[:parent_message_id_header],
      :'References'  => @message[:message_references_header],
    )
  end

end
