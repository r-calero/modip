class Notifier < ActionMailer::Base
  # Sender address; Gmail requires it to be the SMTP account or one of its aliases.
  default :from => ENV['MODIP_SMTP_FROM'] || ENV['MODIP_SMTP_USER'] || "someone@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.docking_compound.subject
  #
  def docking_compound(emails, order_hash, query, first, second, third)
    @greeting = "Hi"
    @order_hash = order_hash
    @query = query
    @first, @second, @third = first, second, third
    mail :to => emails, :subject => 'MODIP: Compound Docking Confirmation [not reply]'
  end
end
