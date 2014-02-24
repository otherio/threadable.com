class Threadable::MailgunEvent < MethodObject

  def call threadable, params
    @threadable = threadable
    @params = params

    return unless params['organization']

    work_around_gmail_image_proxy!

    case params["event"]
      when 'opened'
        return open!
      when 'bounced'
        return
      when 'complained'
        return complain!
      when 'delivered'
        return
      when 'dropped'
        return
      else
        return
      end
  end

  attr_reader :threadable, :params

  private

  def message
    organization.messages.find_by_message_id_header(params['Message-Id'])
  end

  def organization
    threadable.organizations.find_by_slug(params['organization'])
  end

  def recipient
    organization.members.find_by_email_address(params['recipient'])
  end

  def work_around_gmail_image_proxy!
    return unless params['user-agent'] =~ /GoogleImageProxy/
    @params['client-name'] = 'GMail'
    @params['client-os'] = 'Unknown'
  end

  def open!
    # this doesn't make any database queries, because it has to be very fast.
    return unless params['recipient-id']
    threadable.track_for_user(params['recipient-id'], "Opened Message", {
      "ip"           => params["ip"          ],
      "country"      => params["country"     ],
      "region"       => params["region"      ],
      "city"         => params["city"        ],
      "user-agent"   => params["user-agent"  ],
      "device-type"  => params["device-type" ],
      "client-type"  => params["client-type" ],
      "client-name"  => params["client-name" ],
      "client-os"    => params["client-os"   ],
      "organization" => params["organization"],
    })
  end

  def complain!
    mixpanel_args = {
      "conversation"  => message.conversation.slug,
      "subject"       => message.subject,
      "organization"  => organization.slug,
    }
    threadable.track_for_user(recipient.id, "Spam Complaint", mixpanel_args)

    threadable.emails.send_email_async(:spam_complaint, @params.merge(mixpanel_args))
  end

end
