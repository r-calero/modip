# Outgoing e-mail (docking notifications, account confirmation, password
# reset). Values come from the MODIP_SMTP_* variables. This must run during
# initialization: ActionMailer ignores settings changed after `initialize!`.
unless Rails.env.test?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.smtp_settings = {
    :address => ENV['MODIP_SMTP_ADDRESS'].presence || "smtp.gmail.com",
    :port => (ENV['MODIP_SMTP_PORT'].presence || 587).to_i,
    :authentication => (ENV['MODIP_SMTP_AUTHENTICATION'].presence || "plain").to_sym,
    :user_name => ENV['MODIP_SMTP_USER'].presence,
    :password => ENV['MODIP_SMTP_PASSWORD'].presence,
    :enable_starttls_auto => ENV['MODIP_SMTP_STARTTLS'] != 'false'
  }
end
