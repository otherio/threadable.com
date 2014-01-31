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

    reply_to_address = @conversation.canonical_formatted_email_address

    @message_url = conversation_url(@organization, 'my', @conversation, anchor: "message-#{@message.id}")
    @new_task_url = "mailto:#{URI::encode(@organization.formatted_task_email_address)}"
    @new_conversation_url = "mailto:#{URI::encode(@organization.formatted_email_address)}"

    to_addresses = as_address_objects(@message.to_header.to_s)
    cc_addresses = as_address_objects(@message.cc_header.to_s)

    @missing_addresses = missing_covered_addresses([to_addresses, cc_addresses].flatten)
    @has_groups = @conversation.groups.count > 0
    sender_is_a_member = @message.creator.present? && @organization.members.include?(@message.creator)

    to_addresses = transform_stale_group_references(to_addresses)
    to_addresses = correct_covered_email_addresses(to_addresses)
    to_addresses = filter_out_recipients(to_addresses)
    to_addresses = filter_organization_email_addresses(to_addresses)

    if to_addresses.empty?
      # if there are missing addresses, use those.
      if @missing_addresses.present? && !@missing_addresses_inserted
        to_addresses = @missing_addresses
        @missing_addresses_inserted = true
      else
        # all the covered addresses are in the cc. steal them.
        to_addresses = formatted_email_addresses
      end
    end

    cc_addresses = transform_stale_group_references(cc_addresses)
    cc_addresses = filter_out_recipients(cc_addresses)
    cc_addresses = subtract_addresses(cc_addresses, to_addresses)
    cc_addresses = correct_covered_email_addresses(cc_addresses)
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
      :'List-ID'           => @organization.formatted_list_id,
      :'List-Archive'      => "<#{conversations_url(@organization,'my')}>",
      :'List-Unsubscribe'  => "<#{@unsubscribe_url}>",
      :'List-Post'         => "<mailto:#{@organization.email_address}>, <#{compose_conversation_url(@organization, 'my')}>"
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
      if IdentifyCoveredEmailAddress.call(email_address)
        @conversation.all_email_addresses.include?(email_address.address) ? email_address : Mail::Address.new(@organization_email_address)
      else
        email_address
      end
    end
  end

  def filter_organization_email_addresses email_addresses
    organization_email_address = Mail::Address.new(@organization_email_address)
    addresses_to_insert = @has_groups ? @missing_addresses : organization_email_address

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

  def missing_covered_addresses header_addresses
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

  def find_covered_addresses addresses
    addresses.find_all{ |email_address| IdentifyCoveredEmailAddress.call(email_address) }
  end

  def correct_covered_email_addresses email_addresses
    email_address_pairs = formatted_email_addresses.map do |formatted_email_address|
      [formatted_email_address.address, formatted_email_address]
    end
    email_address_hash = Hash[email_address_pairs]

    email_addresses.map do |email_address|
      email_address_hash[email_address.address] || email_address
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
end
