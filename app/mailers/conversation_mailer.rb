# Encoding: UTF-8
require 'prepare_email_subject'

class ConversationMailer < Covered::Mailer

  add_template_helper EmailHelper

  def conversation_message(organization, message, recipient)
    @organization, @message, @recipient = organization, message, recipient
    @conversation = @message.conversation
    @task = @conversation if @conversation.task?

    @organization_email_address = @task ? @organization.formatted_task_email_address : @organization.formatted_email_address

    subject_tag = "[#{@organization.subject_tag}]"
    subject_tag = "[✔\uFE0E]#{subject_tag}" if @task
    buffer_length = 100 - @message.body_plain.length
    buffer_length = 0 if buffer_length < 0
    @message_summary = "#{@message.body_plain.to_s[0,200]}#{' ' * buffer_length}#{'_' * buffer_length}"

    @subject = PrepareEmailSubject.call(@organization, @message)
    @subject.sub!(/^\s*(re:\s?)*/i, "\\1#{subject_tag} ")

    from = @message.from || @message.creator.try(:formatted_email_address ) || @organization.formatted_email_address
    unsubscribe_token = OrganizationUnsubscribeToken.encrypt(@organization.id, @recipient.id)
    @unsubscribe_url = organization_unsubscribe_url(@organization.slug, unsubscribe_token)

    @message.attachments.all.each do |attachment|
      attachments[attachment.filename] = {
        :mime_type => attachment.mimetype,
        :content   => attachment.content,
      }
    end

    reply_to_address = @task ? @organization.formatted_task_email_address : @organization.formatted_email_address

    @message_url = conversation_url(@organization, 'my', @conversation, anchor: "message-#{@message.id}")
    @new_task_url = "mailto:#{URI::encode(@organization.formatted_task_email_address)}"
    @new_conversation_url = "mailto:#{URI::encode(@organization.formatted_email_address)}"
    # @mute_conversation_url = mute_organization_conversation_url(@organization, @conversation)

    to = begin
      to_addresses = Mail::AddressList.new(@message.to_header.to_s).addresses
      to_addresses = correct_organization_email_address(to_addresses)
      to_addresses = filter_out_organization_members(to_addresses)
      to_addresses.map(&:to_s).join(', ').presence || nil
    end

    sender_is_a_member = @message.creator.present? && @organization.members.include?(@message.creator)

    cc = begin
      cc_addresses = Mail::AddressList.new(@message.cc_header.to_s).addresses
      cc_addresses = filter_out_organization_members(cc_addresses)
      cc_addresses = to.present? ? correct_organization_email_address(cc_addresses) : filter_out_organization_email_address(cc_addresses)
      cc_addresses << @message.from if !sender_is_a_member && @message.from.present?
      cc_addresses.map(&:to_s).join(', ').presence || nil
    end

    to ||= reply_to_address

    email = mail(
      :css                 => 'email',
      :'from'              => from,
      :'to'                => to,
      :'cc'                => cc,
      :'subject'           => @subject,
      :'Reply-To'          => reply_to_address,
      :'Message-ID'        => @message.message_id_header,
      :'References'        => @message.references_header,
      :'Date'              => @message.date_header,
      :'In-Reply-To'       => @message.parent_message.try(:message_id_header),
      :'List-ID'           => @organization.formatted_list_id,
      :'List-Archive'      => "<#{conversations_url(@organization,'my')}>",
      :'List-Unsubscribe'  => "<#{@unsubscribe_url}>",
      :'List-Post'         => "<mailto:#{@organization.email_address}>, <#{compose_conversation_url(@organization, 'my')}>"
    )

    email.smtp_envelope_from = @task ? @organization.task_email_address : @organization.email_address
    email.smtp_envelope_to = @recipient.email_address.to_s

    email
  end

  private

  def organization_member_emails_addresses
    @organization_member_emails_addresses ||= @organization.members.email_addresses.map(&:address)
  end

  def filter_out_organization_members email_addresses
    email_addresses.select do |email_address|
      organization_member_emails_addresses.exclude? email_address.address
    end
  end

  def filter_out_organization_email_address email_addresses
    email_addresses.select do |email_address|
      @organization.email_addresses.exclude? email_address.address
    end
  end

  def correct_organization_email_address email_addresses
    email_addresses.map do |email_address|
      if @organization.email_addresses.include? email_address.address
        Mail::Address.new(@organization_email_address)
      else
        email_address
      end
    end
  end

end
