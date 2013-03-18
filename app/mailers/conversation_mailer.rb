# Encoding: UTF-8
class ConversationMailer < ActionMailer::Base

  def conversation_message(data)
    @data = data

    subject_tag = @data[:project_slug][0..6]

    subject = @data[:message_subject].include?("[#{subject_tag}]") ?
      @data[:message_subject] : "[#{subject_tag}] #{@data[:message_subject]}"

    # add a check mark to the subect if the conversation is a task, and if the subject doesn't already include one
    subject = "✔ #{subject}" if @data[:is_a_task] && !subject.include?("✔")

    from = %("#{@data[:sender_name]}" <#{@data[:sender_email]}>)

    unsubscribe_token = UnsubscribeToken.encrypt(@data[:project_id], @data[:recipient_id])
    @unsubscribe_url = project_unsubscribe_url(@data[:project_slug], unsubscribe_token)

    mail(
      :'to'          => %(#{@data[:recipient_name].inspect} <#{@data[:recipient_email]}>),
      :'subject'     => subject,
      :'from'        => from,
      :'Reply-To'    => @data[:reply_to],
      :'Message-ID'  => @data[:message_message_id_header],
      :'In-Reply-To' => @data[:parent_message_id_header],
      :'References'  => @data[:message_references_header],
    )
  end

end
