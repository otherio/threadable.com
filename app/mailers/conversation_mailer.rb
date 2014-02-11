# Encoding: UTF-8
require 'prepare_email_subject'

class ConversationMailer < Threadable::Mailer

  add_template_helper EmailHelper

  def conversation_message(organization, message, recipient)
    @organization, @message, @recipient = organization, message, recipient
    @conversation = @message.conversation
    @task = @conversation if @conversation.task?

    @organization_email_address = @task ? @organization.formatted_task_email_address : @organization.formatted_email_address

    buffer_length = 100 - @message.body_plain.to_s.length
    buffer_length = 0 if buffer_length < 0
    @message_summary = "#{@message.body_plain.to_s[0,200]}#{' ' * buffer_length}#{'_' * buffer_length}"

    @subject = PrepareEmailSubject.call(@organization, @message)
    @subject.sub!(/^\s*(re:\s?)*/i, "\\1#{@conversation.subject_tag} ")

    from = @message.from || @message.creator.try(:formatted_email_address ) || @organization.formatted_email_address
    unsubscribe_token = OrganizationUnsubscribeToken.encrypt(@organization.id, @recipient.id)
    @unsubscribe_url = organization_unsubscribe_url(@organization.slug, unsubscribe_token)

    @message.attachments.all.each do |attachment|
      attachments[attachment.filename] = {
        :mime_type => attachment.mimetype,
        :content   => attachment.content,
        :content_id => attachment.content_id,
      }

      if attachment.content_id
        attachments[attachment.filename][:content_id] = attachment.content_id
        attachments[attachment.filename][:'X-Attachment-Id'] = attachment.content_id.gsub(/[<>]/, '')
      end
    end

    reply_to_address = @conversation.canonical_formatted_email_address

    @message_url = conversation_url(@organization, 'my', @conversation, anchor: "message-#{@message.id}")

    if has_many_groups
      groups = @conversation.groups.all
      @new_task_url = "mailto:#{groups.map(&:task_email_address).join(',')}"
      @new_conversation_url = "mailto:#{groups.map(&:email_address).join(',')}"
      @group_indicator_options = {
        name: 'Many Groups',
        class: 'many',
        color: '#95a5a6',
      }
    elsif has_groups
      group = @conversation.groups.all.first
      @new_task_url = "mailto:#{URI::encode(group.formatted_task_email_address)}"
      @new_conversation_url = "mailto:#{URI::encode(group.formatted_email_address)}"
      @group_indicator_options = {
        name: "+#{truncate_with_ellipsis(group.name)}",
        class: 'grouped',
        color: group.color,
      }
    else
      @new_task_url = "mailto:#{URI::encode(@organization.formatted_task_email_address)}"
      @new_conversation_url = "mailto:#{URI::encode(@organization.formatted_email_address)}"
      @group_indicator_options = {
        name: "Ungrouped",
        class: 'ungrouped',
        color: "#ecf0f1",
      }
    end

    begin
      to_addresses = as_address_objects(@message.to_header.to_s)
      cc_addresses = as_address_objects(@message.cc_header.to_s)
    rescue Mail::Field::ParseError
      # sometimes people remove the quotes and leave the colon.
      to_addresses = as_address_objects(@message.to_header.to_ascii.gsub(/:/, ''))
      cc_addresses = as_address_objects(@message.cc_header.to_ascii.gsub(/:/, ''))
    end

    @missing_addresses = missing_threadable_addresses([to_addresses, cc_addresses].flatten)
    sender_is_a_member = @message.creator.present? && @organization.members.include?(@message.creator)

    to_addresses = transform_stale_group_references(to_addresses)
    to_addresses = correct_threadable_email_addresses(to_addresses)
    to_addresses = filter_out_recipients(to_addresses)
    to_addresses = filter_organization_email_addresses(to_addresses)

    if to_addresses.empty?
      # if there are missing addresses, use those.
      if @missing_addresses.present? && !@missing_addresses_inserted
        to_addresses = @missing_addresses
        @missing_addresses_inserted = true
      else
        # all the threadable addresses are in the cc. steal them.
        to_addresses = formatted_email_addresses
      end
    end

    cc_addresses = transform_stale_group_references(cc_addresses)
    cc_addresses = filter_out_recipients(cc_addresses)
    cc_addresses = subtract_addresses(cc_addresses, to_addresses)
    cc_addresses = correct_threadable_email_addresses(cc_addresses)
    cc_addresses << Mail::Address.new(@message.from) if !sender_is_a_member && @message.from.present?
    cc_addresses = filter_organization_email_addresses(cc_addresses)

    to = to_addresses.map(&:to_s).join(', ').presence || nil
    cc = cc_addresses.map(&:to_s).join(', ').presence || nil

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
      :'List-ID'           => @conversation.list_id,
      :'List-Archive'      => "<#{conversations_url(@organization, 'my')}>",
      :'List-Unsubscribe'  => "<#{@unsubscribe_url}>",
      :'List-Post'         => "<mailto:#{@conversation.list_post_email_address}>, <#{compose_conversation_url(@organization, 'my')}>"
    )

    email.smtp_envelope_from = @conversation.canonical_email_address
    email.smtp_envelope_to = @recipient.email_address.to_s

    email
  end

  private

  def recipient_email_addresses
    @recipient_email_addresses ||= @conversation.recipients.all.map(&:email_address)
  end

  def filter_out_recipients email_addresses
    email_addresses.select do |email_address|
      recipient_email_addresses.exclude? email_address.address
    end
  end

  def transform_stale_group_references email_addresses
    email_addresses.map do |email_address|
      if IdentifyThreadableEmailAddress.call(email_address)
        @conversation.all_email_addresses.include?(email_address.address) ? email_address : Mail::Address.new(@organization_email_address)
      else
        email_address
      end
    end
  end

  def filter_organization_email_addresses email_addresses
    organization_email_address = Mail::Address.new(@organization_email_address)
    addresses_to_insert = has_groups ? @missing_addresses : organization_email_address

    email_addresses.map do |email_address|
      if email_address.address == organization_email_address.address
        unless @missing_addresses_inserted
          @missing_addresses_inserted = true
          addresses_to_insert
        else
          nil
        end
      else
        email_address
      end
    end.flatten.compact
  end

  def missing_threadable_addresses header_addresses
    header_addresses = header_addresses.map do |email_address|
      email_address.address
    end
    formatted_email_addresses = @conversation.formatted_email_addresses.map{ |addr| Mail::Address.new(addr) }
    formatted_email_addresses.map{ |addr| header_addresses.include?(addr.address) ? nil : addr }.compact
  end

  def subtract_addresses master_list, remove_list
    remove_list_addresses = remove_list.map{ |addr| addr.address }
    master_list.reject{ |addr| remove_list_addresses.include? addr.address }
  end

  def correct_threadable_email_addresses email_addresses
    map = formatted_email_addresses.inject({}) do |hash, formatted_email_address|
      hash.update formatted_email_address.local => formatted_email_address
    end
    email_addresses.map do |email_address|
      next email_address unless IdentifyThreadableEmailAddress.call(email_address)
      local = email_address.local
      local.gsub!(/--/, '+')
      map[local] || email_address
    end
  end

  def formatted_email_addresses
    @formatted_email_addresses ||= as_address_objects(@conversation.formatted_email_addresses)
  end

  def as_address_objects email_addresses
    if email_addresses.kind_of?(Array)
      email_addresses = email_addresses.join(', ')
    end
    Mail::AddressList.new(email_addresses).addresses
  end

  def has_groups
    @has_groups ||= @conversation.groups.count > 0
  end

  def has_many_groups
    @has_many_groups ||= @conversation.groups.count > 1
  end

  def truncate_with_ellipsis string, length = 21
    output = string[0,length]
    if output != string
      output = output.strip + '...'
    end
    output
  end
end
