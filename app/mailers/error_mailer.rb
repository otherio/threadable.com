class ErrorMailer < Threadable::Mailer

  def spam_complaint(params)
    @params = PP.pp(params, "")  #format nicely
    mail(
      to:      'threadable+abuse@threadable.com',
      from:    "Threadable abuse <threadable+abuse@threadable.com>",
      subject: "Spam complaint",
    )
  end

  def billing_callback_error(organization_slug)
    @organization_slug = organization_slug
    mail(
      to:      'accounts@threadable.threadable.com',
      from:    "Threadable accounts <accounts@threadable.threadable.com>",
      subject: "Billing Callback Error",
    )
  end
end
