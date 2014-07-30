# Encoding: UTF-8
require 'prepare_email_subject'
require 'verify_dmarc'

class ConversationMailer < Threadable::Mailer

  add_template_helper EmailHelper

  def conversation_message(organization, message, recipient)
    @organization, @message, @recipient = organization, message, recipient
    @conversation = @message.conversation
    @task = @conversation if @conversation.task?

    @header_separator_url = "https://s3.amazonaws.com/multify-production/superable-specialable-threadable-dividerable-headerable.png"
    @footer_separator_url = "https://s3.amazonaws.com/multify-production/superable-specialable-threadable-dividerable-footerable.png"

    @organization_email_address = @task ? @organization.formatted_task_email_address : @organization.formatted_email_address

    buffer_length = 100 - @message.body_plain.to_s.length
    buffer_length = 0 if buffer_length < 0
    @message_summary = "#{@message.body_plain.to_s[0,200]}#{' ' * buffer_length}#{'_' * buffer_length}"

    @show_mail_buttons = recipient.show_mail_buttons?

    @subject = PrepareEmailSubject.call(@organization, @message)
    @subject.sub!(/^\s*(re:\s?)*/i, "\\1#{@conversation.subject_tag} ")
    @subject = "Re: #{@subject}" if @subject !~ /re:/i && @message.parent_message.present?

    unsubscribe_token = OrganizationUnsubscribeToken.encrypt(@organization.id, @recipient.id)
    @unsubscribe_url = organization_unsubscribe_url(@organization.slug, unsubscribe_token)

    @message.attachments.not_inline.each do |attachment|
      params = attachment_params attachment
      filename = params.delete :filename

      attachments[filename] = params

      if attachment.content_id
        attachments[filename][:content_id] = attachment.content_id
        attachments[filename][:'X-Attachment-Id'] = attachment.content_id.gsub(/[<>]/, '')
      end
    end

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
    else
      group = @conversation.groups.all.first
      @new_task_url = "mailto:#{URI::encode(group.task_email_address)}"
      @new_conversation_url = "mailto:#{URI::encode(group.email_address)}"
      @group_indicator_options = {
        name: "#{truncate_with_ellipsis(group.name)}",
        class: 'grouped',
        color: group.color,
      }
    end

    to_addresses = canonicalize_email_addresses(@message.to_header.to_s)
    cc_addresses = canonicalize_email_addresses(@message.cc_header.to_s)

    @missing_addresses = missing_threadable_addresses([to_addresses, cc_addresses].flatten.compact)
    sender_is_a_member = @message.creator.present? && @organization.members.include?(@message.creator)

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

    cc_addresses = filter_out_recipients(cc_addresses)
    cc_addresses = subtract_addresses(cc_addresses, to_addresses)

    if !sender_is_a_member && @message.from.present? && @recipient.munge_reply_to?
      cc_addresses << as_address_objects(@message.from).first
    elsif @recipient.munge_reply_to? && !dmarc_verified
      cc_addresses << from_address
    end

    cc_addresses = filter_organization_email_addresses(cc_addresses)

    to = to_addresses.map(&:to_s).join(', ').presence || nil
    cc = cc_addresses.map(&:to_s).join(', ').presence || nil

    to ||= @conversation.formatted_email_addresses

    if dmarc_verified
      from = from_address
    else
      name = from_address.name
      name ||= from_address.local
      from = Mail::Address.new("#{name} via Threadable <placeholder@#{threadable.email_host}>")
    end

    email_params = {
      :css                   => 'email',
      :'from'                => from,
      :'to'                  => to,
      :'cc'                  => cc,
      :'subject'             => @subject,
      :'Reply-To'            => reply_to_address,
      :'Message-ID'          => @message.message_id_header,
      :'References'          => @message.references_header,
      :'Date'                => @message.date_header,
      :'In-Reply-To'         => @message.parent_message.try(:message_id_header),
      :'List-ID'             => @conversation.list_id,
      :'List-Archive'        => "<#{conversations_url(@organization, 'my')}>",
      :'List-Unsubscribe'    => "<#{@unsubscribe_url}>",
      :'List-Post'           => "<mailto:#{@conversation.list_post_email_address}>, <#{compose_conversation_url(@organization, 'my')}>",
      :'X-Mailgun-Variables' => {'organization' => organization.slug, 'recipient-id' => @recipient.id}.to_json,
    }.delete_if { |k, v| !v.present? }

    email = prepare_message email_params

    email.alternative_content_types_with_attachment(
      :text => render_to_string(:template => "conversation_mailer/conversation_message.text"),
      :html => render_to_string(:template => "conversation_mailer/conversation_message.html")
    ) do |inline_attachments|
      @message.attachments.inline.each do |attachment|
        params = attachment_params attachment
        filename = params.delete :filename

        inline_attachments[filename] = params

        if attachment.content_id
          inline_attachments[filename][:content_id] = attachment.content_id
          inline_attachments[filename][:'X-Attachment-Id'] = attachment.content_id.gsub(/[<>]/, '')
        end
      end
    end

    email.smtp_envelope_from = @conversation.internal_email_address
    email.smtp_envelope_to = @recipient.email_address.to_s

    email
  end

  private

  def attach_file attachment, message_attachments
    filename = attachment.filename.gsub(/"/, '') # quotes break everything. actionmailer should deal with this better.

    if attachment.mimetype == 'message/rfc822'
      # for some reason just attaching these doesn't work
      filename = "#{filename}.eml" unless filename =~ /\.eml\Z/
      message_attachments[filename] = {
        :content    => attachment.content,
      }
    else
      message_attachments[filename] = {
        :content    => attachment.content,
        :encoding   => 'binary',
        :mime_type  => attachment.mimetype,
      }
    end

    if attachment.content_id
      message_attachments[filename][:content_id] = attachment.content_id
      message_attachments[filename][:'X-Attachment-Id'] = attachment.content_id.gsub(/[<>]/, '')
    end
  end

  def attachment_params attachment
    filename = attachment.filename.gsub(/"/, '') # quotes break everything. actionmailer should deal with this better.

    if attachment.mimetype == 'message/rfc822'
      # for some reason just attaching these doesn't work
      filename = "#{filename}.eml" unless filename =~ /\.eml\Z/
      {
        content:  attachment.content,
        filename: filename,
      }
    else
      {
        content:   attachment.content,
        encoding:  'binary',
        mime_type: attachment.mimetype,
        filename:  filename,
      }
    end
  end

  def reply_to_address
    return @conversation.formatted_email_addresses if @recipient.munge_reply_to?
    return from_address.to_s unless dmarc_verified
    nil
  end

  def from_address
    @from_address ||= as_address_objects(@message.from || @message.creator.try(:formatted_email_address ) || @organization.formatted_email_address).first
  end

  def dmarc_verified
    @dmarc_verified ||= VerifyDmarc.call(from_address)
  end

  def recipient_email_addresses
    @recipient_email_addresses ||= @conversation.recipients.all.map(&:email_address)
  end

  def filter_out_recipients email_addresses
    email_addresses.select do |email_address|
      recipient_email_addresses.exclude? email_address.address
    end
  end

  def filter_organization_email_addresses email_addresses
    email_addresses.map do |email_address|
      if email_address.address == organization_email_address_object.address
        if @missing_addresses_inserted
          nil
        else
          @missing_addresses_inserted = true

          addresses_to_insert = @missing_addresses
          if @conversation.in_primary_group? && ! addresses_to_insert.map(&:address).include?(organization_email_address_object.address)
            addresses_to_insert += [organization_email_address_object]
          end
          addresses_to_insert
        end
      else
        email_address
      end
    end.flatten.compact
  end

  def missing_threadable_addresses header_addresses
    header_addresses = header_addresses.map(&:address)
    formatted_email_addresses.map{ |addr| header_addresses.include?(addr.address) ? nil : addr }.compact
  end

  def subtract_addresses master_list, remove_list
    remove_list_addresses = remove_list.map{ |addr| addr.address }
    master_list.reject{ |addr| remove_list_addresses.include? addr.address }
  end

  def canonicalize_email_addresses email_addresses
    as_address_objects(email_addresses).map do |email_address|
      canonicalize_email_address email_address
    end
  end

  def canonicalize_email_address email_address
    return email_address unless @organization.matches_email_address?(email_address)

    local = email_address.local.gsub(/--/, '+')
    host = email_address.domain.split('.').first

    unless host == @organization.slug
      local = local.split('+', 2).last
    end

    # if found, convert to the canonical address format
    # if not found, convert to the org (primary group) email address
    return conversation_email_addresses_map[local] || organization_email_address_object
  end

  def formatted_email_addresses
    @formatted_email_addresses ||= as_address_objects(@conversation.formatted_email_addresses)
  end

  def conversation_email_addresses_map
    @conversation_email_addresses_map ||= formatted_email_addresses.inject({}) do |hash, formatted_email_address|
      hash.update formatted_email_address.local => formatted_email_address
    end
  end

  def as_address_objects email_addresses
    if email_addresses.kind_of?(Array)
      email_addresses = email_addresses.join(', ')
    end

    begin
      Mail::AddressList.new(email_addresses).addresses
    rescue Mail::Field::ParseError
      # sometimes people remove the quotes and leave the colon, or the phrase part contains unsupported unicode.
      # so, this works around shortcomings in Mail's AddressListParser
      Mail::AddressList.new(email_addresses.to_ascii.gsub(/:/, '')).addresses
    end
  end

  def has_many_groups
    @has_many_groups ||= @conversation.groups.count > 1
  end

  def organization_email_address_object
    @organization_email_address_object ||= Mail::Address.new(@organization_email_address)
  end

  def truncate_with_ellipsis string, length = 21
    output = string[0,length]
    if output != string
      output = output.strip + '...'
    end
    output
  end
end
