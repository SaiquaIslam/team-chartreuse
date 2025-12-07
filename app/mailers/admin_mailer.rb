class AdminMailer < ApplicationMailer
  default to: "admin@example.com"

  def contact_email(from_email, subject, body, corpse_flower = nil)
    @from_email    = from_email
    @body          = body
    @corpse_flower = corpse_flower

    mail(from: from_email, subject: subject)
  end
end