class ErrorMailer < Threadable::Mailer

  def spam_complaint(params)
    @params = PP.pp(params, "")  #format nicely
    mail(
      to:      'threadable+abuse@threadable.com',
      from:    "Threadable abuse <threadable+abuse@threadable.com>",
      subject: "Spam complaint",
    )
  end

end
